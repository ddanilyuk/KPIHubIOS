//
//  AppStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import Routes
import URLRouting

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


        case debug

        case signOut
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClient
        let campusClient: CampusClient

        static var live: Self {
            let apiClient: APIClient = .live(
//                router: rootRouter.baseURL("http://127.0.0.1:8080")
                router: rootRouter.baseURL("http://kpihub.xyz")
            )
            let userDefaultsClient: UserDefaultsClient = .live()
            let campusClient: CampusClient = .init(userDefaultsClient: userDefaultsClient)
            return Self(
                apiClient: apiClient,
                userDefaultsClient: userDefaultsClient,
                campusClient: campusClient
            )
        }
    }

    // MARK: - Reducer

    static var reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .appDelegate(.didFinishLaunching):
            if environment.userDefaultsClient.get(for: .group) != nil ||
               environment.userDefaultsClient.get(for: .campusUserInfo) != nil {
                state.set(.main)
            } else {
                state.set(.login)
            }

            return Effect(value: .debug)
                .deferred(for: 10, scheduler: DispatchQueue.main)

        case .login(.delegate(.done)):
            state.set(.main)
            return .none

        case .debug:
//            environment.userDefaultsClient.remove(for: .campusUserInfo)
//            environment.campusClient.updateState()
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

}

// MARK: App.Environment + Extensions

extension App.Environment {

    var appDelegate: AppDelegate.Environment {
        AppDelegate.Environment(
        )
    }

    var login: Login.Environment {
        Login.Environment(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient,
            campusClient: campusClient
        )
    }

    var main: Main.Environment {
        Main.Environment(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient,
            campusClient: campusClient
        )
    }

}
