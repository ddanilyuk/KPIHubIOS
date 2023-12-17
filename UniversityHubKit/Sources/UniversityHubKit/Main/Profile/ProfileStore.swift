//
//  ProfileStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

//import ComposableArchitecture
//import Combine
//
//@Reducer
//public struct Profile: Reducer {
//    @ObservableState
//    public struct State: Equatable {
//        var profileHome: ProfileHome.State
//        var path = StackState<Path.State>()
//        
//        init() {
//            profileHome = ProfileHome.State()
//        }
//    }
//    
//    public enum Action: Equatable {
//        case profileHome(ProfileHome.Action)
//        case delegate(Delegate)
//        case path(StackAction<Path.State, Path.Action>)
//        
//        public enum Delegate: Equatable {
//            case selectRozkladTab
//            case selectCampusTab
//        }
//    }
//        
//    var core: some ReducerOf<Self> {
//        Reduce { state, action in
//            switch action {
//            case .profileHome(.routeAction(.rozklad)):
//                return .send(.delegate(.selectRozkladTab))
//
//            case .profileHome(.routeAction(.campus)):
//                return .send(.delegate(.selectCampusTab))
//
//            case .profileHome(.routeAction(.forDevelopers)):
//                let forDevelopersState = ForDevelopers.State()
//                state.path.append(.forDevelopers(forDevelopersState))
//                return .none
//                
//            case .profileHome:
//                return .none
//                
//            case .path:
//                return .none
//                
//            case .delegate:
//                return .none
//            }
//        }
//    }
//    
//    public var body: some ReducerOf<Self> {
//        Scope(state: \.profileHome, action: \.profileHome) {
//            ProfileHome()
//        }
//        core
//            .forEach(\.path, action: \.path) {
//                Path()
//            }
//    }
//}
