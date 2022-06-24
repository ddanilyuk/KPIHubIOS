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

        @BindableState var selectedTab: Tab

        enum Tab: Hashable {
            case rozklad
            case campus
            case profile
        }

        var rozklad: Rozklad.State
        var campus: Campus.State
        var profile: Profile.State

        init() {
            rozklad = Rozklad.State()
            campus = Campus.State()
            profile = Profile.State()

            selectedTab = .rozklad
        }
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case rozklad(Rozklad.Action)
        case campus(Campus.Action)
        case profile(Profile.Action)

        case binding(BindingAction<State>)
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClient
        let rozkladClient: RozkladClient
        let campusClient: CampusClient
        let currentDateClient: CurrentDateClient
    }

    // MARK: - Reducer

    static let coreReducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .profile(.delegate(.selectRozkladTab)):
            state.selectedTab = .rozklad
            return .none

        case .profile(.delegate(.selectCampusTab)):
            state.selectedTab = .campus
            return .none

        case .rozklad:
            return .none
            
        case .campus:
            return .none

        case .profile:
            return .none

        case .binding:
            return .none
        }
    }
    .binding()

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

// MARK: Main.Environment + Extensions

extension Main.Environment {

    var rozklad: Rozklad.Environment {
        Rozklad.Environment(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient,
            rozkladClient: rozkladClient,
            currentDateClient: currentDateClient
        )
    }

    var campus: Campus.Environment {
        Campus.Environment(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient,
            campusClient: campusClient,
            rozkladClient: rozkladClient
        )
    }

    var profile: Profile.Environment {
        Profile.Environment(
            userDefaultsClient: userDefaultsClient,
            rozkladClient: rozkladClient,
            campusClient: campusClient
        )
    }

}
