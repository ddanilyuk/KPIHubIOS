//
//  AppFeature.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import Routes
import URLRouting
import Foundation
import Firebase

public struct AppDelegateFeature: Reducer {
    public struct State: Equatable { }
    
    public enum Action: Equatable {
        case didFinishLaunching
    }
    
    @Dependency(\.firebaseService) var firebaseService
    
    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .didFinishLaunching:
                firebaseService.setup()
                return .none
            }
        }
    }
}


public struct AppFeature: Reducer {
    public struct State: Equatable {
        public var appDelegate = AppDelegateFeature.State()
//        var path: Path.State?
        public init() { }
    }
    
    public enum Action: Equatable {
        case appDelegate(AppDelegateFeature.Action)
//        case path(Path.Action)
    }
    
    @Dependency(\.userDefaultsService) var userDefaultsService
    
    public init() { } 
    
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            return .none
//            switch action {
//            case .appDelegate(.didFinishLaunching):
//                if userDefaultsService.get(for: .onboardingPassed) {
//                    state.path = .main(MainFlow.State())
//                } else {
//                    state.path = .onboarding(OnboardingFlow.State())
//                }
//                return .none
//                                
//            case .path(.onboarding(.output(.done))):
//                state.path = .main(MainFlow.State())
//                return .none
//                
//            case .appDelegate:
//                return .none
//                
//            case .path:
//                return .none
//            }
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \State.appDelegate, action: /Action.appDelegate) {
            AppDelegateFeature()
        }
        core
//        core.ifLet(\.path, action: /Action.path) {
//            Path()
//        }
    }
}
