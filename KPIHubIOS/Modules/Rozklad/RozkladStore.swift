//
//  RozkladStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators
import IdentifiedCollections
import Foundation

struct Rozklad: ReducerProtocol {

    // MARK: - State

    struct State: Equatable, IdentifiedRouterState {
        var routes: IdentifiedArrayOf<Route<ScreenProvider.State>>

        init() {
            self.routes = []
        }
    }

    // MARK: - Action

    enum Action: Equatable, IdentifiedRouterAction {
        case onSetup

        case updateRozkladState(RozkladClientState.State)
        case setGroupRozklad
        case setGroupPicker

        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)
    }

    // MARK: - Environment
    
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons

    // MARK: - Reducer
    
    @ReducerBuilder<State, Action>
    var core: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onSetup:
                return Effect.merge(
                    Effect(value: .updateRozkladState(rozkladClientState.subject.value)),
                    Effect.run { subscriber in
                        rozkladClientState.subject
                            .dropFirst()
                            .removeDuplicates()
                            .receive(on: DispatchQueue.main)
                            .sink { state in
                                subscriber.send(.updateRozkladState(state))
                            }
                    }
                )

            case let .updateRozkladState(state):
                switch state {
                case .selected:
                    return Effect(value: .setGroupRozklad)
                case .notSelected:
                    return Effect(value: .setGroupPicker)
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
                        .groupPicker(GroupPicker.State(mode: .rozkladTab)),
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
                rozkladClientState.commit()
                rozkladClientLessons.commit()
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
    }

    var body: some ReducerProtocol<State, Action> {
        Reduce(
            AnyReducer(Rozklad.ScreenProvider())
                .forEachIdentifiedRoute(environment: { () })
                .withRouteReducer(AnyReducer(core)),
            environment: ()
        )
    }

}
