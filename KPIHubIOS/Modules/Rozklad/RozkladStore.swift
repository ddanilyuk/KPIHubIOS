//
//  RozkladStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators

struct Rozklad {

    // MARK: - State

    struct State: Equatable, IdentifiedRouterState {
        var routes: IdentifiedArrayOf<Route<ScreenProvider.State>>

        init() {
            self.routes = [
                .root(.groupLessons(GroupLessons.State()), embedInNavigationView: true)
            ]
        }
    }

    // MARK: - Action

    enum Action: Equatable, IdentifiedRouterAction {
        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
    }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .routeAction:
            return .none

        case .updateRoutes:
            return .none
        }
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        ScreenProvider.reducer
            .forEachIdentifiedRoute(environment: { $0 })
            .withRouteReducer(reducerCore)
    )

}
