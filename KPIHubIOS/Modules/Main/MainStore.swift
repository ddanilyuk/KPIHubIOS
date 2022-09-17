//
//  MainStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators

struct Main: ReducerProtocol {

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
    
    // MARK: - Reducer
    
    @ReducerBuilder<State, Action>
    var core: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
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
    }

    var body: some ReducerProtocol<State, Action> {
        Scope(state: \State.rozklad, action: /Action.rozklad) {
            Rozklad()
        }
        Scope(state: \State.campus, action: /Action.campus) {
            Campus()
        }
        Scope(state: \State.profile, action: /Action.profile) {
            Profile()
        }
        core
    }

}
