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
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClientable
        let keychainClient: KeychainClientable
        let rozkladClient: RozkladClient
        let campusClient: CampusClient
        let currentDateClient: CurrentDateClient

        static var live: Self {
            let apiClient: APIClient = .live(
//                router: rootRouter.baseURL("http://192.168.31.89:8080")
                router: rootRouter.baseURL("http://kpihub.xyz")
            )
            let userDefaultsClient: UserDefaultsClientable = .live()
            let keychainClient: KeychainClientable = .live()
            let rozkladClient: RozkladClient = .live(
                userDefaultsClient: userDefaultsClient
            )
            let campusClient: CampusClient = .live(
                apiClient: apiClient,
                userDefaultsClient: userDefaultsClient,
                keychainClient: keychainClient
            )
            let currentDateClient: CurrentDateClient = .live(
                userDefaultsClient: userDefaultsClient,
                rozkladClient: rozkladClient
            )

            return Self(
                apiClient: apiClient,
                userDefaultsClient: userDefaultsClient,
                keychainClient: keychainClient,
                rozkladClient: rozkladClient,
                campusClient: campusClient,
                currentDateClient: currentDateClient
            )
        }
    }

    // MARK: - Reducer

    static var reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .appDelegate(.didFinishLaunching):
            if environment.userDefaultsClient.get(for: .onboardingPassed) {
                state.set(.main)
            } else {
                state.set(.login)
            }
            return .none

        case .login(.delegate(.done)):
            state.set(.main)
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

}

// MARK: App.Environment + Extensions

extension App.Environment {

    var appDelegate: AppDelegate.Environment {
        AppDelegate.Environment()
    }

    var login: Login.Environment {
        Login.Environment(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient,
            rozkladClient: rozkladClient,
            campusClient: campusClient
        )
    }

    var main: Main.Environment {
        Main.Environment(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient,
            rozkladClient: rozkladClient,
            campusClient: campusClient,
            currentDateClient: currentDateClient
        )
    }

}
