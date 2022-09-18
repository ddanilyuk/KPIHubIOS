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

private enum CampusClientStateKey: TestDependencyKey {
    static let testValue = CampusClientState.mock()
}

extension CampusClientStateKey: DependencyKey {
    static let liveValue = CampusClientState.live(
        userDefaultsClient: DependencyValues.current.userDefaultsClient,
        keychainClient: DependencyValues.current.keychainClient
    )
}

extension DependencyValues {
    var campusClientState: CampusClientState {
        get { self[CampusClientStateKey.self] }
        set { self[CampusClientStateKey.self] = newValue }
    }
}

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
