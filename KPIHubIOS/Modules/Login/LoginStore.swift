//
//  LoginStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators
import AVFoundation

struct Login {

    // MARK: - State

    struct State: Equatable, IdentifiedRouterState {
        var routes: IdentifiedArrayOf<Route<ScreenProvider.State>>

        init() {
            self.routes = [
                .root(.onboarding(Onboarding.State()), embedInNavigationView: true)
            ]
        }
    }

    // MARK: - Action

    enum Action: Equatable, IdentifiedRouterAction {
        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case done
        }
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
    }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .routeAction(_, .onboarding(.routeAction(.groupPicker))):
            let groupPickerState = GroupPicker.State()
            state.routes.push(.groupPicker(groupPickerState))
            return .none

        case .routeAction(_, .onboarding(.routeAction(.campusLogin))):
            let campusLoginState = CampusLogin.State()
            state.routes.push(.campusLogin(campusLoginState))
            return .none

        case .routeAction(_, .campusLogin(.routeAction(.groupPicker))):
            let groupPickerState = GroupPicker.State()
            state.routes.push(.groupPicker(groupPickerState))
            return .none

        case .routeAction(_, .campusLogin(.routeAction(.loggedIn))):
            return Effect(value: .delegate(.done))

        case .routeAction(_, .groupPicker(.routeAction(.selected))):
            return Effect(value: .delegate(.done))

        case .routeAction:
            return .none

        case .updateRoutes:
            return .none

        case .delegate:
            return .none
        }
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        Login.ScreenProvider.reducer
            .forEachIdentifiedRoute(environment: { $0 })
            .withRouteReducer(reducerCore)
    )

}
