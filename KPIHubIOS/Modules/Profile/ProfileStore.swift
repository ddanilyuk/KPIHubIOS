//
//  ProfileStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

struct Profile {

    // MARK: - State

    struct State: Equatable {
        var name: String = ""
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
        case logOutCampus
        case logOutGroup
    }

    // MARK: - Environment

    struct Environment {
        let userDefaultsClient: UserDefaultsClient
        let rozkladClient: RozkladClient
        let campusClient: CampusClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onAppear:
            if let userInfo = environment.userDefaultsClient.get(for: .campusUserInfo) {
                state.name = userInfo.fullName
            }
            return .none

        case .logOutCampus:
            environment.campusClient.logOut()
            return .none

        case .logOutGroup:
            environment.rozkladClient.logOut()
            return .none
        }
    }

}
