//
//  CampusClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine

final class CampusClient {

    // MARK: - State

    enum State {
        case loggedOut
        case loggedIn
    }

    // MARK: - Properties

    private let userDefaultsClient: UserDefaultsClient

    lazy var state: CurrentValueSubject<State, Never> = {
        if userDefaultsClient.get(for: .campusUserInfo) != nil {
            return .init(.loggedIn)
        } else {
            return .init(.loggedOut)
        }
    }()

    // MARK: - Lifecycle

    static func live(userDefaultsClient: UserDefaultsClient) -> CampusClient {
        CampusClient(userDefaultsClient: userDefaultsClient)
    }

    private init(userDefaultsClient: UserDefaultsClient) {
        self.userDefaultsClient = userDefaultsClient
    }

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
