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
import ComposableArchitecture

private enum CampusClientStateKey: TestDependencyKey {
//    static let liveValue = RozkladClientState.live()
    static let testValue = CampusClientState.mock()
}

extension DependencyValues {
    var campusClientState: CampusClientState {
        get { self[CampusClientStateKey.self] }
        set { self[CampusClientStateKey.self] = newValue }
    }
}

private enum CampusClientStudySheetKey: TestDependencyKey {
//    static let liveValue = RozkladClientState.live()
    static let testValue = CampusClientStudySheet.mock()
}

extension DependencyValues {
    var campusClientStudySheet: CampusClientStudySheet {
        get { self[CampusClientStudySheetKey.self] }
        set { self[CampusClientStudySheetKey.self] = newValue }
    }
}


struct CampusClient {

    let state: CampusClientState
    let studySheet: CampusClientStudySheet

    static func live(
        apiClient: APIClient,
        userDefaultsClient: UserDefaultsClientable,
        keychainClient: KeychainClientable
    ) -> CampusClient {
        CampusClient(
            state: .live(
                userDefaultsClient: userDefaultsClient,
                keychainClient: keychainClient
            ),
            studySheet: .live(
                apiClient: apiClient,
                userDefaultsClient: userDefaultsClient,
                keychainClient: keychainClient
            )
        )
    }

    static func mock() -> CampusClient {
        CampusClient(
            state: .mock(),
            studySheet: .mock()
        )
    }

}

// MARK: - CampusClientState

struct CampusClientState {

    enum State: Equatable {
        case loggedIn(CampusUserInfo)
        case loggedOut
    }

    struct LoginRequest {
        let credentials: CampusCredentials
        let userInfo: CampusUserInfo
    }

    let subject: CurrentValueSubject<State, Never>

    let login: (ClientValue<LoginRequest>) -> Void
    let logout: (ClientValue<Void>) -> Void
    let commit: () -> Void

    static func live(
        userDefaultsClient: UserDefaultsClientable,
        keychainClient: KeychainClientable
    ) -> CampusClientState {
        let subject = CurrentValueSubject<State, Never>(.loggedOut)
        let commit: () -> Void = {
            if let campusUserInfo = userDefaultsClient.get(for: .campusUserInfo) {
                subject.value = .loggedIn(campusUserInfo)
            } else {
                subject.value = .loggedOut
            }
        }
        commit()
        return CampusClientState(
            subject: subject,
            login: { clientValue in
                let userInfo = clientValue.value.userInfo
                let credentials = clientValue.value.credentials
                userDefaultsClient.set(userInfo, for: .campusUserInfo)
                keychainClient.set(credentials.username, for: .campusUsername)
                keychainClient.set(credentials.password, for: .campusPassword)
                if clientValue.commitChanges {
                    commit()
                }
            },
            logout: { clientValue in
                userDefaultsClient.remove(for: .campusUserInfo)
                try? keychainClient.remove(for: .campusUsername)
                try? keychainClient.remove(for: .campusPassword)
                if clientValue.commitChanges {
                    commit()
                }
            },
            commit: commit
        )
    }

    static func mock() -> CampusClientState {
        return CampusClientState(
            subject: CurrentValueSubject<State, Never>(
                .loggedIn(CampusUserInfo.mock)
            ),
            login: { _ in },
            logout: { _ in },
            commit: { }
        )
    }

}

// MARK: - CampusClientStudySheet

struct CampusClientStudySheet {

    enum State: Equatable {
        case notLoading
        case loading
        case loaded([StudySheetItem])
    }

    let subject: CurrentValueSubject<State, Never>

    let load: () -> Effect<Void, Never>
    let clean: () -> Void

    static func live(
        apiClient: APIClient,
        userDefaultsClient: UserDefaultsClientable,
        keychainClient: KeychainClientable
    ) -> CampusClientStudySheet {

        let subject = CurrentValueSubject<State, Never>(.notLoading)

        return CampusClientStudySheet(
            subject: subject,
            load: {
                guard
                    let username = keychainClient.get(key: .campusUsername),
                    let password = keychainClient.get(key: .campusPassword)
                else {
                    subject.send(.notLoading)
                    return .none
                }
                let campusLoginQuery = CampusLoginQuery(
                    username: username,
                    password: password
                )
                subject.send(.loading)
                let task: Effect<[StudySheetItem], Error> = Effect.task {
                    let result = try await apiClient.decodedResponse(
                        for: .api(.campus(.studySheet(campusLoginQuery))),
                        as: StudySheetResponse.self
                    )
                    return result.value.studySheet.map { StudySheetItem(studySheetItemResponse: $0) }
                }
                return task
                    .on(
                        value: { subject.send(.loaded($0)) },
                        error: { _ in subject.send(.notLoading) }
                    )
                    .ignoreOutput(setOutputType: Void.self)
                    .ignoreFailure()
                    .eraseToEffect()
            },
            clean: {
                subject.send(.notLoading)
            }
        )
    }

    static func mock() -> CampusClientStudySheet {
        CampusClientStudySheet(
            subject: CurrentValueSubject<State, Never>(.notLoading),
            load: { .none },
            clean: { }
        )
    }

}
