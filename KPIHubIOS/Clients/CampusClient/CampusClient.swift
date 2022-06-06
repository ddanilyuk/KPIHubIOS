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

    enum State: Equatable {
        case loggedIn(CampusUserInfo)
        case loggedOut
    }

    // MARK: - Properties

    private let userDefaultsClient: UserDefaultsClient

    lazy var stateSubject: CurrentValueSubject<State, Never> = {
        if let campusUserInfo = userDefaultsClient.get(for: .campusUserInfo) {
            return .init(.loggedIn(campusUserInfo))
        } else {
            return .init(.loggedOut)
        }
    }()

    enum StudySheetState: Equatable {
        case notLoading
        case loading
        case loaded([StudySheetItem])
    }

    var studySheetSubject: CurrentValueSubject<StudySheetState, Never> = .init(.notLoading)

    let apiClient: APIClient

    var studySheetCancellable: Cancellable?

    func startLoading() {
        guard let credentials = userDefaultsClient.get(for: .campusCredentials) else {
            studySheetSubject.send(.notLoading)
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
        studySheetSubject.send(.loading)
        studySheetCancellable?.cancel()
        studySheetCancellable = task.sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure:
                    self?.studySheetSubject.send(.notLoading)
                }
            },
            receiveValue: { [weak self] value in
                self?.studySheetSubject.send(.loaded(value))
            }
        )
    }

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
        self.apiClient = apiClient
        self.userDefaultsClient = userDefaultsClient
    }

    func logOut() {
        stateSubject.value = .loggedOut
        userDefaultsClient.remove(for: .campusUserInfo)
        userDefaultsClient.remove(for: .campusCredentials)
    }

    func updateState() {
        if let campusUserInfo = userDefaultsClient.get(for: .campusUserInfo) {
            stateSubject.value = .loggedIn(campusUserInfo)
        } else {
            stateSubject.value = .loggedOut
        }
    }
    
}
