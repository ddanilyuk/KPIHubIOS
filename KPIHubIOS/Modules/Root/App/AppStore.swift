//
//  AppStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import Routes
import URLRouting

typealias APIClient = URLRoutingClient<RootRoute>

struct App {

    // MARK: - State

    struct State: Equatable {
        var appDelegate: AppDelegate.State = AppDelegate.State()
        var login: Login.State?
        var main: Main.State?

        mutating func set(_ currentState: CurrentState) {
            switch currentState {
            case .login:
                self.login = Login.State()
                self.main = .none

            case .main:
                self.main = Main.State()
                self.login = .none
            }
        }

        enum CurrentState {
            case login
            case main
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case appDelegate(AppDelegate.Action)
        case login(Login.Action)
        case main(Main.Action)

        case signOut
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let useDefaultsClient: UserDefaultsService

        static var live: Self {
            let apiClient: APIClient = .live(
                router: rootRouter.baseURL("http://kpihub.xyz")
            )
            let useDefaultsClient: UserDefaultsService = .live()
            return Self(
                apiClient: apiClient,
                useDefaultsClient: useDefaultsClient
            )
        }
    }

    // MARK: - Reducer

    static var reducer = Reducer<State, Action, Environment>.combine(
        AppDelegate.reducer
            .pullback(
                state: \State.appDelegate,
                action: /Action.appDelegate,
                environment: { $0.appDelegate }
            ),

        Login.reducer
            .optional()
            .pullback(
                state: \State.login,
                action: /Action.login,
                environment: { $0.login }
            ),

        Main.reducer
            .optional()
            .pullback(
                state: \State.main,
                action: /Action.main,
                environment: { $0.main }
            ),

        reducerCore
    )
    .debug()

    static var reducerCore = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .appDelegate(.didFinishLaunching):
            state.set(.main)
            return .none

        case .signOut:
            return .none

        case .appDelegate:
            return .none

        case .login:
            return .none

        case .main:
            return .none
        }
    }
}

// MARK: App.Environment + Extensions

extension App.Environment {

    var appDelegate: AppDelegate.Environment {
        AppDelegate.Environment(
        )
    }

    var login: Login.Environment {
        Login.Environment(
            apiClient: apiClient
        )
    }

    var main: Main.Environment {
        Main.Environment(
            apiClient: apiClient
        )
    }

}
