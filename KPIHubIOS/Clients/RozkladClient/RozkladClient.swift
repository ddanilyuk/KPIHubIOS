//
//  RozkladClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine

class RozkladClient {

    enum State {
        case selected
        case notSelected
    }

    var userDefaultsClient: UserDefaultsClient

    init(userDefaultsClient: UserDefaultsClient) {
        self.userDefaultsClient = userDefaultsClient
    }

    lazy var state: CurrentValueSubject<State, Never> = {
        if userDefaultsClient.get(for: .group) != nil {
            return .init(.selected)
        } else {
            return .init(.notSelected)
        }
    }()

    func logOut() {
        state.value = .notSelected
    }

    func updateState() {
        if userDefaultsClient.get(for: .campusUserInfo) != nil {
            state.value = .selected
        } else {
            state.value = .notSelected
        }
    }

}
