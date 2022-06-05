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
            if environment.userDefaultsClient.get(for: .group) != nil {
                state.routes = [.root(.groupLessons(GroupLessons.State()), embedInNavigationView: true)]
            } else {
                state.routes = [.root(.groupPicker(GroupPicker.State()), embedInNavigationView: true)]
            }
            return .none

        case let .routeAction(_, .groupLessons(.routeAction(.openDetails(lesson)))):
            let lessonDetailsState = LessonDetails.State(
                lesson: lesson
            )
            state.routes.push(.lessonDetails(lessonDetailsState))
            return .none

        case .routeAction(_, .groupPicker(.routeAction(.done))):
            state.routes = [.root(.groupLessons(GroupLessons.State()), embedInNavigationView: true)]
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
