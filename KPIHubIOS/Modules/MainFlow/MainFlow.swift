//
//  MainStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import RozkladKit
import CampusFeature

@Reducer
struct MainFlow: Reducer {
    @ObservableState
    struct State: Equatable {
        var selectedTab: Tab
        var rozklad: RozkladFlow.State
        var campus: Campus.State
        var profile: ProfileFlow.State
        
        init() {
            selectedTab = .rozklad
            rozklad = RozkladFlow.State()
            campus = Campus.State()
            profile = ProfileFlow.State()
        }
    }
    
    enum Action: BindableAction, ViewAction {
        case rozklad(RozkladFlow.Action)
        case campus(Campus.Action)
        case profile(ProfileFlow.Action)
        
        case binding(BindingAction<State>)
        case view(View)
        
        enum View: Equatable {
            case onAppear
        }
    }
    
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
//            case .profile(.delegate(.selectRozkladTab)):
//                state.selectedTab = .rozklad
//                return .none
//                
//            case .profile(.delegate(.selectCampusTab)):
//                state.selectedTab = .campus
//                return .none
                
            case .view(.onAppear):
                return .merge(
                    .send(.rozklad(.onSetup))
//                    .send(.campus(.onSetup))
                )
                
            case .binding:
                return .none
                
            case .rozklad:
                return .none
                
            case .campus:
                return .none
//                
            case .profile:
                return .none
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.rozklad, action: \.rozklad) {
            RozkladFlow()
        }
        Scope(state: \.campus, action: \.campus) {
            Campus()
        }
        Scope(state: \.profile, action: \.profile) {
            ProfileFlow()
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
