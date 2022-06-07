//
//  CampusClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import Routes
import ComposableArchitecture

final class CampusClient {

    // MARK: - State

    final class StateModule {

        enum State: Equatable {
            case loggedIn(CampusUserInfo)
            case loggedOut
        }

        private let userDefaultsClient: UserDefaultsClient

        lazy var subject: CurrentValueSubject<State, Never> = {
            if let campusUserInfo = userDefaultsClient.get(for: .campusUserInfo) {
                return .init(.loggedIn(campusUserInfo))
            } else {
                return .init(.loggedOut)
            }
        }()

        init(userDefaultsClient: UserDefaultsClient) {
            self.userDefaultsClient = userDefaultsClient
        }

        func login(
            credentials: CampusCredentials,
            userInfo: CampusUserInfo,
            commitChanges: Bool
        ) {
            userDefaultsClient.set(userInfo, for: .campusUserInfo)
            userDefaultsClient.set(credentials, for: .campusCredentials)
            if commitChanges {
                commit()
            }
        }

        func logOut(commitChanges: Bool) {
            userDefaultsClient.remove(for: .campusUserInfo)
            userDefaultsClient.remove(for: .campusCredentials)
            if commitChanges {
                commit()
            }
        }

        func commit() {
            if let campusUserInfo = userDefaultsClient.get(for: .campusUserInfo) {
                subject.send(.loggedIn(campusUserInfo))
            } else {
                subject.send(.loggedOut)
            }
        }
    }

    var state: StateModule

    // MARK: - StudySheet

    final class StudySheetModule {

        enum State: Equatable {
            case notLoading
            case loading
            case loaded([StudySheetItem])
        }

        private let userDefaultsClient: UserDefaultsClient
        private let apiClient: APIClient
        private var studySheetCancellable: Cancellable?

        var subject: CurrentValueSubject<State, Never> = .init(.notLoading)

        init(
            userDefaultsClient: UserDefaultsClient,
            apiClient: APIClient
        ) {
            self.userDefaultsClient = userDefaultsClient
            self.apiClient = apiClient
        }

        func load() {
            guard let credentials = userDefaultsClient.get(for: .campusCredentials) else {
                subject.send(.notLoading)
                return
            }
            let campusLoginQuery = CampusLoginQuery(
                username: credentials.username,
                password: credentials.password
            )
            let task: Effect<[StudySheetItem], Error> = Effect.task { [weak self] in
                guard let self = self else {
                    throw APIError.unknown
                }
                let result = try await self.apiClient.decodedResponse(
                    for: .api(.campus(.studySheet(campusLoginQuery))),
                    as: StudySheetResponse.self
                )
                return result.value.studySheet.map { StudySheetItem(studySheetItemResponse: $0) }
            }
            subject.send(.loading)
            studySheetCancellable?.cancel()
            studySheetCancellable = task.sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        return
                    case .failure:
                        self?.subject.send(.notLoading)
                    }
                },
                receiveValue: { [weak self] value in
                    self?.subject.send(.loaded(value))
                }
            )
        }

        func removeLoaded() {
            studySheetCancellable?.cancel()
            subject.send(.notLoading)
        }

    }

    var studySheet: StudySheetModule

    // MARK: - Lifecycle

    static func live(
        apiClient: APIClient,
        userDefaultsClient: UserDefaultsClient
    ) -> CampusClient {
        CampusClient(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient
        )
    }

    private init(apiClient: APIClient, userDefaultsClient: UserDefaultsClient) {
        self.state = StateModule(userDefaultsClient: userDefaultsClient)
        self.studySheet = StudySheetModule(userDefaultsClient: userDefaultsClient, apiClient: apiClient)
    }

}
