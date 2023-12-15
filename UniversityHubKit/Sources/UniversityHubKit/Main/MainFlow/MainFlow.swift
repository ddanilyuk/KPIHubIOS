//
//  MainStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import RozkladKit

@Reducer
public struct MainFlow: Reducer {
    @ObservableState
    public struct State: Equatable {
        var selectedTab: Tab
        var rozklad: RozkladFlow.State
        var campus: Campus.State
        var profile: Profile.State
        
        init() {
            selectedTab = .rozklad
            rozklad = RozkladFlow.State()
            campus = Campus.State()
            profile = Profile.State()
        }
    }
    
    public enum Action: Equatable, BindableAction {
        case rozklad(RozkladFlow.Action)
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
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.rozklad, action: \.rozklad) {
            RozkladFlow()
        }
        Scope(state: \.campus, action: \.campus) {
            Campus()
        }
        Scope(state: \.profile, action: \.profile) {
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
