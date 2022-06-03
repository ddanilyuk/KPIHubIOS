//
//  CampusLoginStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 03.06.2022.
//

import ComposableArchitecture

struct CampusLogin {

    // MARK: - State

    struct State: Equatable {
        @BindableState var username: String = "dda77177"
        @BindableState var password: String = "4a78dd74"

        var loginButtonEnabled: Bool = true
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case login

        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction {
            case groupPicker
            case loggedIn
        }
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .binding(\.$username):
            state.loginButtonEnabled = !state.username.isEmpty && !state.password.isEmpty
            return .none

        case .binding(\.$password):
            state.loginButtonEnabled = !state.username.isEmpty && !state.password.isEmpty
            return .none

        case .login:
            return .none
            
        case .binding:
            return .none

        case .routeAction:
            return .none
        }
    }
    .binding()


}
