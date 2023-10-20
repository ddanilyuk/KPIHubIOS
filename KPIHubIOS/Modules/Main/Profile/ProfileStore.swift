//
//  ProfileStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import Combine
import ForDevelopersFeature

// ProfileFlowCoordinator
struct Profile: Reducer {
    struct State: Equatable {
        var profileHome: ProfileHome.State
        var path = StackState<ScreenProvider.State>()
        
        init() {
            profileHome = ProfileHome.State()
        }
    }
    
    enum Action: Equatable {
        case profileHome(ProfileHome.Action)
        case delegate(Delegate)
        case path(StackAction<ScreenProvider.State, ScreenProvider.Action>)
        
        enum Delegate: Equatable {
            case selectRozkladTab
            case selectCampusTab
        }
    }
        
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .profileHome(.routeAction(.rozklad)):
                return .send(.delegate(.selectRozkladTab))

            case .profileHome(.routeAction(.campus)):
                return .send(.delegate(.selectCampusTab))

            case .profileHome(.routeAction(.forDevelopers)):
                let forDevelopersState = ForDevelopersFeature.State()
                state.path.append(.forDevelopers(forDevelopersState))
                return .none
                
            case .profileHome:
                return .none
                
            case .path:
                return .none
                
            case .delegate:
                return .none
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.profileHome, action: /Action.profileHome) {
            ProfileHome()
        }
        core.forEach(\.path, action: /Action.path) {
            ScreenProvider()
        }
    }
}
