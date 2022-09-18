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
    
    // MARK: - Reducer
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .routeAction:
                return .none
            }
        }
    }

}
