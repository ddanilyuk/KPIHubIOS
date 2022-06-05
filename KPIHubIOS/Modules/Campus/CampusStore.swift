//
//  CampusStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators

struct Campus {

    // MARK: - State

    struct State: Equatable, IdentifiedRouterState {
        var routes: IdentifiedArrayOf<Route<ScreenProvider.State>>

        init() {
            self.routes = [.root(.empty(.init()))]
        }
    }

    // MARK: - Action

    enum Action: Equatable, IdentifiedRouterAction {
        case onAppear

        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClient
    }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onAppear:
            if environment.userDefaultsClient.get(for: .campusUserInfo) != nil {
                state.routes = [
                    .root(
                        .campusHome(CampusHome.State()),
                        embedInNavigationView: true
                    )
                ]
            } else {
                state.routes = [
                    .root(
                        .campusLogin(CampusLogin.State(mode: .onlyCampus)),
                        embedInNavigationView: true
                    )
                ]
            }
            return .none

        case .routeAction(_, .campusLogin(.routeAction(.done))):
            state.routes = [
                .root(
                    .campusHome(CampusHome.State()),
                    embedInNavigationView: true
                )
            ]
            return .none

        case .routeAction(_, action: .campusHome(.routeAction(.studySheet))):
            let studySheetState = StudySheet.State()
            state.routes.push(.studySheet(studySheetState))
            return .none

        case .routeAction(_, .studySheet(.routeAction(.itemDetail))):
            let studySheetItemDetailState = StudySheetItemDetail.State()
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
