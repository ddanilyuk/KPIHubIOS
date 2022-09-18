//
//  OnboardingStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

struct Onboarding: ReducerProtocol {
    
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
    
    var body: some ReducerProtocol<State, Action> {
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
