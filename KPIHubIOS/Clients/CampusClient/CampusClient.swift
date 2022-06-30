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

struct CampusClientable {

    let state: CampusClientableState
    let studySheet: CampusClientableStudySheet

    static func live(
        apiClient: APIClient,
        userDefaultsClient: UserDefaultsClientable,
        keychainClient: KeychainClientable
    ) -> CampusClientable {
        CampusClientable(
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

    static func mock() -> CampusClientable {
        CampusClientable(
            state: .mock(),
            studySheet: .mock()
        )
    }

}

// MARK: - CampusClientableState

struct CampusClientableState {

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
    ) -> CampusClientableState {
        let subject = CurrentValueSubject<State, Never>(.loggedOut)
        let commit: () -> Void = {
            if let campusUserInfo = userDefaultsClient.get(for: .campusUserInfo) {
                subject.value = .loggedIn(campusUserInfo)
            } else {
                subject.value = .loggedOut
            }
        }
        commit()
        return CampusClientableState(
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

    static func mock() -> CampusClientableState {
        return CampusClientableState(
            subject: CurrentValueSubject<State, Never>(
                .loggedIn(CampusUserInfo.mock)
            ),
            login: { _ in },
            logout: { _ in },
            commit: { }
        )
    }

}

// MARK: - CampusClientableStudySheet

struct CampusClientableStudySheet {

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
    ) -> CampusClientableStudySheet {

        let subject = CurrentValueSubject<State, Never>(.notLoading)

        return CampusClientableStudySheet(
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

    static func mock() -> CampusClientableStudySheet {
        CampusClientableStudySheet(
            subject: CurrentValueSubject<State, Never>(.notLoading),
            load: { .none },
            clean: { }
        )
    }

}
