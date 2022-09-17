//
//  GroupRozkladStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import IdentifiedCollections
import ComposableArchitecture
import Foundation

struct GroupRozklad: ReducerProtocol {

    // MARK: - State

    struct State: Equatable {

        var currentDay: Lesson.Day?
        var currentWeek: Lesson.Week = .first
        var currentLesson: CurrentLesson?
        var nextLessonID: Lesson.ID?

        var groupName: String = ""
        var lessons: IdentifiedArrayOf<Lesson> = []
        var sections: [Section] = []

        var isAppeared: Bool = false

        @BindableState var needToScrollOnAppear: Bool = false
        var scrollTo: Lesson.ID?

        var lessonCells: IdentifiedArrayOf<LessonCell.State> {
            get {
                sections
                    .map { $0.lessonCells }
                    .reduce(into: [], { $0.append(contentsOf: $1.elements) })
            }
            set {
                lessons = IdentifiedArrayOf(uniqueElements: newValue.map { $0.lesson })
                sections = [State.Section](lessons: lessons)
            }
        }

        init() {
            self.lessons = []
            self.sections = [Section](lessons: [])
        }

    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case onAppear
        case onDisappear

        case updateLessons(IdentifiedArrayOf<Lesson>)
        case updateCurrentDate

        case scrollToNearest(_ condition: Bool = true)
        case resetScrollTo

        case lessonCells(id: LessonResponse.ID, action: LessonCell.Action)
        case routeAction(RouteAction)
        case binding(BindingAction<State>)

        enum RouteAction: Equatable {
            case openDetails(Lesson)
        }
    }

    // MARK: - Environment
    
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.currentDateClient) var currentDateClient

    // MARK: - Reducer
    
    enum SubscriberCancelID { }

//    @ReducerBuilder<State, Action>
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isAppeared = true
                return Effect.merge(
                    Effect(value: .updateCurrentDate),
                    Effect.concatenate(
                        Effect(value: .updateLessons(rozkladClientLessons.subject.value)),
                        Effect(value: .scrollToNearest(state.needToScrollOnAppear)),
                        Effect(value: .binding(.set(\.$needToScrollOnAppear, false)))
                    ),
                    Effect.run { subscriber in
                        rozkladClientLessons.subject
                            .dropFirst()
                            .receive(on: DispatchQueue.main)
                            .sink { lessons in
                                subscriber.send(.updateLessons(lessons))
                            }
                    },
                    Effect.run { subscriber in
                        currentDateClient.updated
                            .dropFirst()
                            .receive(on: DispatchQueue.main)
                            .sink { _ in
                                subscriber.send(.updateCurrentDate)
                            }
                    }
                )
                .cancellable(id: SubscriberCancelID.self, cancelInFlight: true)

            case .onDisappear:
                state.isAppeared = false
                return .none

            case .updateCurrentDate:
                let oldCurrentLesson = state.currentLesson
                let oldNextLessonID = state.nextLessonID
                state.currentDay = currentDateClient.currentDay.value
                state.currentWeek = currentDateClient.currentWeek.value
                state.currentLesson = currentDateClient.currentLesson.value
                state.nextLessonID = currentDateClient.nextLessonID.value
                state.sections = [State.Section](
                    lessons: state.lessons,
                    currentLesson: state.currentLesson,
                    nextLesson: state.nextLessonID
                )
                if oldCurrentLesson?.lessonID != state.currentLesson?.lessonID || oldNextLessonID != state.nextLessonID {
                    if state.isAppeared {
                        return Effect(value: .scrollToNearest())
                            .delay(for: 0.3, scheduler: DispatchQueue.main)
                            .eraseToEffect()
                    } else {
                        state.needToScrollOnAppear = true
                        return .none
                    }

                } else {
                    return .none
                }

            case let .updateLessons(lessons):
                state.groupName = rozkladClientState.group()?.name ?? "-"
                state.lessons = lessons
                state.sections = [State.Section](
                    lessons: state.lessons,
                    currentLesson: state.currentLesson,
                    nextLesson: state.nextLessonID
                )
                return .none

            case let .scrollToNearest(needToScroll):
                if needToScroll {
                    let scrollTo = state.currentLesson?.lessonID ?? state.nextLessonID
                    state.scrollTo = scrollTo
                }
                return .none

            case .resetScrollTo:
                state.scrollTo = nil
                return .none

            case let .lessonCells(id, .onTap):
                guard
                    let selectedLesson = state.lessons[id: id]
                else {
                    return .none
                }
                return Effect(value: .routeAction(.openDetails(selectedLesson)))

            case .routeAction:
                return .none

            case .lessonCells:
                return .none

            case .binding:
                return .none
            }
        }
        .forEach(\State.lessonCells, action: /Action.lessonCells) {
            LessonCell()
        }
    }
    
//    var body: some ReducerProtocol<State, Action> {
//        Reduce(
//            AnyReducer(GroupRozklad.ScreenProvider())
//                .forEachIdentifiedRoute(environment: { () })
//                .withRouteReducer(AnyReducer(core)),
//            environment: ()
//        )
//    }
    
}
