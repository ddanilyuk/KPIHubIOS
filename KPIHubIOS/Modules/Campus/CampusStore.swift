//
//  CampusStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators
import Combine

struct Campus {

    // MARK: - State

    struct State: Equatable, IdentifiedRouterState {
        var routes: IdentifiedArrayOf<Route<ScreenProvider.State>>

        init() {
            self.routes = [
                .root(.empty(.init()))
//                .root(
//                    .campusHome(CampusHome.State()),
//                    embedInNavigationView: true
//                )
            ]
        }
    }

    // MARK: - Action

    enum Action: Equatable, IdentifiedRouterAction {
        case onSetup
        case onAppear

        case setlogOutState
        case setLoginState

        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClient
        let campusClient: CampusClient
    }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onSetup:
            return Effect.run { subscriber in
                environment.campusClient.state
                    .sink { state in
                        switch state {
                        case .loggedOut:
                            subscriber.send(.setlogOutState)
                        case .loggedIn:
                            subscriber.send(.setLoginState)
                        }
                    }
            }

        case .onAppear:
//            if environment.userDefaultsClient.get(for: .campusUserInfo) != nil {
//                state.routes = [
//                    .root(
//                        .campusHome(CampusHome.State()),
//                        embedInNavigationView: true
//                    )
//                ]
//            } else {
//                state.routes = [
//                    .root(
//                        .campusLogin(CampusLogin.State(mode: .onlyCampus)),
//                        embedInNavigationView: true
//                    )
//                ]
//            }
            return .none

        case .setlogOutState:
            state.routes = [
                .root(
                    .campusLogin(CampusLogin.State(mode: .onlyCampus)),
                    embedInNavigationView: true
                )
            ]
            return .none

        case .setLoginState:
            state.routes = [
                .root(
                    .campusHome(CampusHome.State()),
                    embedInNavigationView: true
                )
            ]
            return .none

        case .routeAction(_, .campusLogin(.routeAction(.done))):
            environment.campusClient.updateState()
            return .none

        case let .routeAction(_, action: .campusHome(.routeAction(.studySheet(items)))):
            let studySheetState = StudySheet.State(items: items)
            state.routes.push(.studySheet(studySheetState))
            return .none

        case let .routeAction(_, .studySheet(.routeAction(.openDetail(item)))):
            let studySheetItemDetailState = StudySheetItemDetail.State(item: item)
            state.routes.push(.studySheetItemDetail(studySheetItemDetailState))
            return .none

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
