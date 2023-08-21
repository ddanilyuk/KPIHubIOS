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
import Firebase

struct AppFeature: Reducer {
    struct State: Equatable {
        var appDelegate: AppDelegateFeature.State = AppDelegateFeature.State()
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

    enum Action: Equatable {
        case appDelegate(AppDelegateFeature.Action)
        case login(Login.Action)
        case main(Main.Action)
    }
    
    @Dependency(\.appConfiguration) var appConfiguration
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.campusClientState) var campusClientState
    @Dependency(\.campusClientStudySheet) var campusClientStudySheet
    @Dependency(\.currentDateClient) var currentDateClient
    
    var core: some ReducerOf<Self> {
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
    
    var body: some ReducerOf<Self> {
        Scope(state: \State.appDelegate, action: /Action.appDelegate) {
            AppDelegateFeature()
        }
        core
            .ifLet(\State.login, action: /Action.login) {
                Login()
            }
            .ifLet(\State.main, action: /Action.main) {
                Main()
            }
    }

}
