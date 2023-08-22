//
//  OnboardingFeature.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

struct OnboardingFeature: Reducer {
    struct State: Equatable { }
    
    enum Action: Equatable {
        case view(View)
        case output(Output)
        
        enum Output: Equatable {
            case groupPicker
            case campusLogin
        }
        
        enum View: Equatable {
            case onAppear
            case loginButtonTapped
            case selectGroupButtonTapped
        }
    }
        
    @Dependency(\.analyticsClient) var analyticsClient
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .view(.onAppear):
                analyticsClient.track(Event.Onboarding.onboardingAppeared)
                return .none
                
            case .view(.loginButtonTapped):
                return .send(.output(.campusLogin))
                
            case .view(.selectGroupButtonTapped):
                return .send(.output(.groupPicker))
                
            case .output:
                return .none
            }
        }
    }
}
