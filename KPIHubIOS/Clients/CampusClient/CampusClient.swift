//
//  CampusClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import Routes
import ComposableArchitecture
import KeychainAccess

final class CampusClient {

    // MARK: - State

    final class StateModule {

        enum State: Equatable {
            case loggedIn(CampusUserInfo)
            case loggedOut
        }

        private let userDefaultsClient: UserDefaultsClientable
        private let keychainClient: KeychainClientable

        lazy var subject: CurrentValueSubject<State, Never> = {
            if let campusUserInfo = userDefaultsClient.get(for: .campusUserInfo) {
                return .init(.loggedIn(campusUserInfo))
            } else {
                return .init(.loggedOut)
            }
        }()

        init(
            userDefaultsClient: UserDefaultsClientable,
            keychainClient: KeychainClientable
        ) {
            self.userDefaultsClient = userDefaultsClient
            self.keychainClient = keychainClient
        }

        func login(
            credentials: CampusCredentials,
            userInfo: CampusUserInfo,
            commitChanges: Bool
        ) {
            userDefaultsClient.set(userInfo, for: .campusUserInfo)
            keychainClient.set(credentials.username, for: .campusUsername)
            keychainClient.set(credentials.password, for: .campusPassword)
            if commitChanges {
                commit()
            }
        }

        func logOut(commitChanges: Bool) {
            userDefaultsClient.remove(for: .campusUserInfo)
            try? keychainClient.remove(for: .campusUsername)
            try? keychainClient.remove(for: .campusPassword)
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

        private let userDefaultsClient: UserDefaultsClientable
        private let keychainClient: KeychainClientable
        private let apiClient: APIClient
        private var studySheetCancellable: Cancellable?

        var subject: CurrentValueSubject<State, Never> = .init(.notLoading)

        init(
            apiClient: APIClient,
            userDefaultsClient: UserDefaultsClientable,
            keychainClient: KeychainClientable
        ) {
            self.apiClient = apiClient
            self.userDefaultsClient = userDefaultsClient
            self.keychainClient = keychainClient
        }

        func load() {
            guard
                let username = keychainClient.get(key: .campusUsername),
                let password = keychainClient.get(key: .campusPassword)
            else {
                subject.send(.notLoading)
                return
            }
            let campusLoginQuery = CampusLoginQuery(
                username: username,
                password: password
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
        userDefaultsClient: UserDefaultsClientable,
        keychainClient: KeychainClientable
    ) -> CampusClient {
        CampusClient(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient,
            keychainClient: keychainClient
        )
    }

    static func mock(
        apiClient: APIClient = .failing,
        userDefaultsClient: UserDefaultsClientable = mockDependencies.userDefaults,
        keychainClient: KeychainClient = .mock()
    ) -> CampusClient {
        CampusClient(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient,
            keychainClient: keychainClient
        )
    }

    private init(
        apiClient: APIClient,
        userDefaultsClient: UserDefaultsClientable,
        keychainClient: KeychainClientable
    ) {
        self.state = StateModule(
            userDefaultsClient: userDefaultsClient,
            keychainClient: keychainClient
        )
        self.studySheet = StudySheetModule(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient,
            keychainClient: keychainClient
        )
    }

}
