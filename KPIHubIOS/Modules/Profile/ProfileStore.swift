//
//  ProfileStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators
import Combine

struct Profile {

    // MARK: - State

    struct State: Equatable, IdentifiedRouterState {
        var routes: IdentifiedArrayOf<Route<ScreenProvider.State>>

        init() {
            self.routes = [.root(.profileHome(.init()), embedInNavigationView: true)]
        }
    }

    // MARK: - Action

    enum Action: Equatable, IdentifiedRouterAction {

        case delegate(Delegate)

        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)

        enum Delegate: Equatable {
            case selectRozkladTab
            case selectCampusTab
        }
    }

    // MARK: - Environment

    struct Environment {
        let userDefaultsClient: UserDefaultsClient
        let rozkladClient: RozkladClient
        let campusClient: CampusClient
    }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .routeAction(_, .profileHome(.routeAction(.rozklad))):
            return Effect(value: .delegate(.selectRozkladTab))

        case .routeAction(_, .profileHome(.routeAction(.campus))):
            return Effect(value: .delegate(.selectCampusTab))

        case .routeAction:
            return .none

        case .updateRoutes:
            return .none

        case .delegate:
            return .none
        }
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        ScreenProvider.reducer
            .forEachIdentifiedRoute(environment: { $0 })
            .withRouteReducer(reducerCore)
    )

}
