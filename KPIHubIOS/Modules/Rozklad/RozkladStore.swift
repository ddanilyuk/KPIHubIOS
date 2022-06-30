//
//  RozkladStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators
import IdentifiedCollections

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

        case onSetup
        case setGroupRozklad
        case setGroupPicker

        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClientable
        let rozkladClient: RozkladClient
        let currentDateClient: CurrentDateClient
    }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onSetup:
            return Effect.run { subscriber in
                environment.rozkladClient.state.subject
                    .receive(on: DispatchQueue.main)
                    .sink { state in
                        switch state {
                        case .selected:
                            subscriber.send(.setGroupRozklad)
                        case .notSelected:
                            subscriber.send(.setGroupPicker)
                        }
                    }
            }

        case .setGroupRozklad:
            state.routes = [
                .root(
                    .groupRozklad(GroupRozklad.State()),
                    embedInNavigationView: true
                )
            ]
            return .none

        case .setGroupPicker:
            state.routes = [
                .root(
                    .groupPicker(GroupPicker.State()),
                    embedInNavigationView: true
                )
            ]
            return .none

        case let .routeAction(_, .groupRozklad(.routeAction(.openDetails(lesson)))):
            let lessonDetailsState = LessonDetails.State(
                lesson: lesson
            )
            state.routes.push(.lessonDetails(lessonDetailsState))
            return .none

        case .routeAction(_, .groupPicker(.routeAction(.done))):
            environment.rozkladClient.state.commit()
            environment.rozkladClient.lessons.commit()
            return .none

        case let .routeAction(_, .lessonDetails(.routeAction(.editNames(lesson)))):
            let editLessonNamesState = EditLessonNames.State(lesson: lesson)
            state.routes.presentSheet(
                .editLessonNames(editLessonNamesState),
                embedInNavigationView: true
            )
            return .none

        case let .routeAction(_, .lessonDetails(.routeAction(.editTeachers(lesson)))):
            let editLessonTeachersState = EditLessonTeachers.State(lesson: lesson)
            state.routes.presentSheet(
                .editLessonTeachers(editLessonTeachersState),
                embedInNavigationView: true
            )
            return .none

        case .routeAction(_, .editLessonNames(.routeAction(.dismiss))):
            state.routes.dismiss()
            return .none

        case .routeAction(_, .editLessonTeachers(.routeAction(.dismiss))):
            state.routes.dismiss()
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
