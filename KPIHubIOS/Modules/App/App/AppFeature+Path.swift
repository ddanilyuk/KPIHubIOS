//
//  AppFeature+Path.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 21.08.2023.
//

import ComposableArchitecture

extension AppFeature {
    struct Path { }
}

extension AppFeature.Path: Reducer {
    enum State: Equatable {
        case onboarding(OnboardingFlow.State)
        case main(MainFlow.State)
    }
    
    enum Action: Equatable {
        case onboarding(OnboardingFlow.Action)
        case main(MainFlow.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.onboarding, action: /Action.onboarding) {
            OnboardingFlow()
        }
        Scope(state: /State.main, action: /Action.main) {
            MainFlow()
        }
    }
}
