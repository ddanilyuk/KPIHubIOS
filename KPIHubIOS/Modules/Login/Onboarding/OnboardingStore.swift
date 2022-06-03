//
//  OnboardingStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

struct Onboarding {

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

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .routeAction:
            return .none
        }
    }

}
