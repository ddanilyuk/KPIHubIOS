//
//  AppFeature+Path.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 21.08.2023.
//

import ComposableArchitecture

extension AppFeature {
    @Reducer
    public struct Destination: Reducer {
        public enum State: Equatable {
            case onboarding(OnboardingFlow.State)
    //        case onboarding(OnboardingFlow.State)
    //        case main(MainFlow.State)
        }
        
        public enum Action: Equatable {
            case onboarding(OnboardingFlow.Action)
    //        case onboarding(OnboardingFlow.Action)
    //        case main(MainFlow.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: /State.onboarding, action: /Action.onboarding) {
                OnboardingFlow()
            }
    //        Scope(state: /State.main, action: /Action.main) {
    //            MainFlow()
    //        }
        }
    }
}

