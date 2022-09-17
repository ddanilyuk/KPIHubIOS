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
        
        case routeAction(RouteAction)
        
        enum RouteAction: Equatable {
            case groupPicker
            case campusLogin
        }
    }
    
    // MARK: - Environment
    
    struct Environment { }
    
    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .routeAction:
            return .none
        }
    }
    
}
