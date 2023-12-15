//
//  AppFeature+Path.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 21.08.2023.
//

import ComposableArchitecture
import GroupPickerFeature

extension AppFeature {
    @Reducer
    struct Destination: Reducer {
        enum State: Equatable {
//            case onboarding(OnboardingFlow.State)
            case main(MainFlow.State)
        }
        
        enum Action: Equatable {
//            case onboarding(OnboardingFlow.Action)
            case main(MainFlow.Action)
        }
        
        var body: some ReducerOf<Self> {
//            Scope(state: \.onboarding, action: \.onboarding) {
//                OnboardingFlow()
//            }
            Scope(state: \.main, action: \.main) {
                MainFlow()
            }
        }
    }
}
