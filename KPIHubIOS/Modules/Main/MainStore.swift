//
//  MainStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

struct MainFlow: Reducer {
    struct State: Equatable {
        @BindingState var selectedTab: Tab
        
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
    
    enum Action: Equatable, BindableAction {
        case rozklad(Rozklad.Action)
        case campus(Campus.Action)
        case profile(Profile.Action)
        
        case binding(BindingAction<State>)
    }
    
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .profile(.delegate(.selectRozkladTab)):
                state.selectedTab = .rozklad
                return .none
                
            case .profile(.delegate(.selectCampusTab)):
                state.selectedTab = .campus
                return .none
                
            case .binding:
                return .none
                
            case .rozklad:
                return .none
                
            case .campus:
                return .none
                
            case .profile:
                return .none
            }
        }
    }
    
    var body: some ReducerOf<Self> {
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

// MARK: Helper models
extension MainFlow {
    enum Tab: Hashable {
        case rozklad
        case campus
        case profile
    }
}
