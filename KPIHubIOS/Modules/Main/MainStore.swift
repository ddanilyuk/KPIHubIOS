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

    struct Environment {
        let apiClient: APIClient
    }

    // MARK: - Reducer

    static let coreReducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .rozklad:
            return .none
            
        case .campus:
            return .none

        case .profile:
            return .none
        }
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        Rozklad.reducer
            .pullback(
                state: \State.rozklad,
                action: /Action.rozklad,
                environment: { $0.rozklad }
            ),

        Campus.reducer
            .pullback(
                state: \State.campus,
                action: /Action.campus,
                environment: { $0.campus }
            ),

        Profile.reducer
            .pullback(
                state: \State.profile,
                action: /Action.profile,
                environment: { $0.profile }
            ),

        coreReducer
    )

}


// MARK: App.Environment + Extensions

extension Main.Environment {

    var rozklad: Rozklad.Environment {
        Rozklad.Environment(
            apiClient: apiClient
        )
    }

    var campus: Campus.Environment {
        Campus.Environment(
        )
    }

    var profile: Profile.Environment {
        Profile.Environment(
        )
    }

}
