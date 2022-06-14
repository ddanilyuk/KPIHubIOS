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
            self.routes = [.root(.empty(.init()))]
        }
    }

    // MARK: - Action

    enum Action: Equatable, IdentifiedRouterAction {
        case onSetup

        case setCampusLogin
        case setCampusHome

        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClient
        let campusClient: CampusClient
        let rozkladClient: RozkladClient
    }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onSetup:
            return Effect.run { subscriber in
                environment.campusClient.state.subject
                    .receive(on: DispatchQueue.main)
                    .sink { state in
                        switch state {
                        case .loggedOut:
                            subscriber.send(.setCampusLogin)
                        case .loggedIn:
                            subscriber.send(.setCampusHome)
                        }
                    }
            }

        case .setCampusLogin:
            state.routes = [
                .root(
                    .campusLogin(CampusLogin.State(mode: .onlyCampus)),
                    embedInNavigationView: true
                )
            ]
            return .none

        case .setCampusHome:
            state.routes = [
                .root(
                    .campusHome(CampusHome.State()),
                    embedInNavigationView: true
                )
            ]
            return .none

        case .routeAction(_, .campusLogin(.routeAction(.done))):
            environment.campusClient.state.commit()
            environment.campusClient.studySheet.load()
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
