//
//  OnboardingStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

struct Onboarding: Reducer {
    
    // MARK: - State
    
    struct State: Equatable { }
    
    // MARK: - Action
    
    enum Action: Equatable {
        case onAppear
        case routeAction(RouteAction)
        
        enum RouteAction: Equatable {
            case groupPicker
            case campusLogin
        }
    }
    
    // MARK: - Reducer
    
    @Dependency(\.analyticsClient) var analyticsClient
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                analyticsClient.track(Event.Onboarding.onboardingAppeared)
                return .none
                
            case .routeAction:
                return .none
            }
        }
    }

}
