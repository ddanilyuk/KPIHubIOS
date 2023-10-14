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
        var path: Path.State?
    }
    
    enum Action: Equatable {
        case appDelegate(AppDelegateFeature.Action)
        case path(Path.Action)
    }
    
    @Dependency(\.userDefaultsService) var userDefaultsService
    
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
                if userDefaultsService.get(for: .onboardingPassed) {
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
        core.ifLet(\.path, action: /Action.path) {
            Path()
        }
    }
}
