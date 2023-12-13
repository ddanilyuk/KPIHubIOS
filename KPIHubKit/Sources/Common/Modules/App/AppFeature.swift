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

@Reducer
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
                // TODO: info plist missing
                // firebaseService.setup()
                return .none
            }
        }
    }
}


@Reducer
public struct AppFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public var appDelegate = AppDelegateFeature.State()
        var destination: Destination.State?
        public init() { }
    }
    
    public enum Action: Equatable {
        case appDelegate(AppDelegateFeature.Action)
        case destination(Destination.Action)
    }
    
    @Dependency(\.userDefaultsService) var userDefaultsService
    
    public init() { } 
    
    @ReducerBuilder<State, Action>
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
//                if userDefaultsService.get(for: .onboardingPassed) {
////                    state.path = .main(MainFlow.State())
//                } else {
//                }
                state.destination = .onboarding(OnboardingFlow.State())
                return .none
                                
//            case .path(.onboarding(.output(.done))):
//                state.path = .main(MainFlow.State())
//                return .none
                
            case .appDelegate:
                return .none
                
            case .destination:
                return .none
            }
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.appDelegate, action: \.appDelegate) {
            AppDelegateFeature()
        }
//        Scope(state: \.path, action: \.path) {
//            Path()
//        }
        core
            .ifLet(\.destination, action: \.destination) {
                Destination()
            }
    }
}
