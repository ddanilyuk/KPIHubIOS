//
//  ProfileStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators
import Combine

struct Profile: ReducerProtocol {
    struct State: Equatable {
        var path = StackState<ScreenProvider.State>()
        
        init() {
            path.append(.profileHome(ProfileHome.State()))
        }
    }
    
    enum Action: Equatable {
        case delegate(Delegate)
        case path(StackAction<ScreenProvider.State, ScreenProvider.Action>)
        
        enum Delegate: Equatable {
            case selectRozkladTab
            case selectCampusTab
        }
    }
        
    @ReducerBuilder<State, Action>
    var core: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .path(.element(_, action: .profileHome(.routeAction(.rozklad)))):
                return .send(.delegate(.selectRozkladTab))
                
            case .path(.element(_, action: .profileHome(.routeAction(.campus)))):
                return .send(.delegate(.selectCampusTab))
                
            case .path(.element(_, action: .profileHome(.routeAction(.forDevelopers)))):
                let forDevelopersState = ForDevelopers.State()
                state.path.append(.forDevelopers(forDevelopersState))
                return .none
                
            case .path:
                return .none
            
            case .delegate:
                return .none
            }
        }
    }

    var body: some ReducerProtocol<State, Action> {
        core.forEach(\.path, action: /Action.path) {
          ScreenProvider()
        }
    }
}
