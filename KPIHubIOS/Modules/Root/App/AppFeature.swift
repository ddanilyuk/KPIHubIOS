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

struct AppFeature: Reducer {
    struct State: Equatable {
        var appDelegate = AppDelegateFeature.State()
        // TODO: Is this valid?
        var path: Path.State = .onboarding(OnboardingFlow.State())
    }
    
    enum Action: Equatable {
        case appDelegate(AppDelegateFeature.Action)
        case path(Path.Action)
    }
    
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
                if userDefaultsClient.get(for: .onboardingPassed) {
                    state.path = .main(MainFlow.State())
                } else {
                    state.path = .onboarding(OnboardingFlow.State())
                }
                return .none
                                
            case .path(.onboarding(.output(.done))):
                state.path = .main(MainFlow.State())
                return .none
                
            case .appDelegate:
                return .none
                
            case .path:
                return .none
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \State.appDelegate, action: /Action.appDelegate) {
            AppDelegateFeature()
        }
        Scope(state: \State.path, action: /Action.path) {
            Path()
        }
        core
    }
}
