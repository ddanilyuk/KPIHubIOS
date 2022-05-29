//
//  MainStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators

struct Main {

    // MARK: - State

    struct State: Equatable {
        var rozklad: Rozklad.State
        var campus: Campus.State
        var profile: Profile.State

        init() {
            rozklad = Rozklad.State()
            campus = Campus.State()
            profile = Profile.State()
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case rozklad(Rozklad.Action)
        case campus(Campus.Action)
        case profile(Profile.Action)
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .rozklad:
            return .none
            
        case .campus:
            return .none

        case .profile:
            return .none
        }
    }

}
