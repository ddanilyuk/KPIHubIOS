//
//  CampusClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine

class CampusClient {

    enum State {
        case loggedOut
        case loggedIn
    }

    var userDefaultsClient: UserDefaultsClient

    internal init(userDefaultsClient: UserDefaultsClient) {
        self.userDefaultsClient = userDefaultsClient
    }

    lazy var state: CurrentValueSubject<State, Never> = {
        if userDefaultsClient.get(for: .campusUserInfo) != nil {
            return .init(.loggedIn)
        } else {
            return .init(.loggedOut)
        }
    }()

    func logOut() {
        state.value = .loggedOut
    }

    func updateState() {
        if userDefaultsClient.get(for: .campusUserInfo) != nil {
            state.value = .loggedIn
        } else {
            state.value = .loggedOut
        }
    }
}
