//
//  AppStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import Routes
import URLRouting
import Foundation

struct App: ReducerProtocol {

    // MARK: - State

    struct State: Equatable {
        var appDelegate: AppDelegateReducer.State = AppDelegateReducer.State()
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
        case appDelegate(AppDelegateReducer.Action)
        case login(Login.Action)
        case main(Main.Action)
    }

    // MARK: - Environment
    
    @Dependency(\.appConfiguration) var appConfiguration
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.campusClientState) var campusClientState
    @Dependency(\.campusClientStudySheet) var campusClientStudySheet
    @Dependency(\.currentDateClient) var currentDateClient

    // MARK: - Reducer

    @ReducerBuilder<State, Action>
    var core: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
                if userDefaultsClient.get(for: .onboardingPassed) {
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
    }
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: \State.appDelegate, action: /Action.appDelegate) {
            AppDelegateReducer()
        }
        .ifLet(\State.login, action: /Action.login) {
            Login()
        }
        .ifLet(\State.main, action: /Action.main) {
            Reduce(
                Main.reducer,
                environment: Main.Environment(
                    appConfiguration: appConfiguration,
                    apiClient: apiClient,
                    userDefaultsClient: userDefaultsClient,
                    rozkladClient: RozkladClient(
                        state: rozkladClientState,
                        lessons: rozkladClientLessons
                    ),
                    campusClient: CampusClient(
                        state: campusClientState,
                        studySheet: campusClientStudySheet
                    ),
                    currentDateClient: currentDateClient
                )
            )
        }

        core
    }

}
