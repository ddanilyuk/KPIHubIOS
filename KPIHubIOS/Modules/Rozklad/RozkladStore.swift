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
        case setGroupLessons
        case setGroupPicker

        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClient
        let rozkladClient: RozkladClient
    }

    // MARK: - Reducer

    static let reducerCore = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onSetup:
            return Effect.run { subscriber in
                environment.rozkladClient.stateSubject
                    .sink { state in
                        switch state {
                        case .selected:
                            subscriber.send(.setGroupLessons)
                        case .notSelected:
                            subscriber.send(.setGroupPicker)
                        }
                    }
            }

        case .setGroupLessons:
            state.routes = [
                .root(
                    .groupLessons(GroupLessons.State()),
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

        case let .routeAction(_, .groupLessons(.routeAction(.openDetails(lesson)))):
            let lessonDetailsState = LessonDetails.State(
                lesson: lesson
            )
            state.routes.push(.lessonDetails(lessonDetailsState))
            return .none

        case .routeAction(_, .groupPicker(.routeAction(.done))):
            environment.rozkladClient.updateState()
            return .none

        case let .routeAction(_, .lessonDetails(.routeAction(.editNames(oldNames, selected)))):
            let editLessonNamesState = EditLessonNames.State(names: oldNames, selected: selected)
            state.routes.presentSheet(.editLessonNames(editLessonNamesState), embedInNavigationView: true)
            return .none

        case let .routeAction(_, .editLessonNames(.routeAction(.save(selected)))):
            guard var oldLesson = state.routes.first(where: /ScreenProvider.State.lessonDetails)?.lesson else {
                return .none
            }
            oldLesson.names = selected
            environment.rozkladClient.modified(lesson: oldLesson)
            state.routes.dismiss()
            return .none

        case .routeAction(_, .editLessonNames(.routeAction(.cancel))):
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
