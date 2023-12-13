//
//  OnboardingFeature.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

public struct OnboardingFeature: Reducer {
    public struct State: Equatable { }
    
    public enum Action: Equatable {
        case view(View)
        case output(Output)
        
        public enum Output: Equatable {
            case groupPicker
            case campusLogin
        }
        
        public enum View: Equatable {
            case onAppear
            case loginButtonTapped
            case selectGroupButtonTapped
        }
    }
    
    @Dependency(\.analyticsService) var analyticsService
    
    public var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .view(.onAppear):
                analyticsService.track(Event.Onboarding.onboardingAppeared)
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
