//
//  GroupRozkladStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import IdentifiedCollections
import ComposableArchitecture
import Foundation

struct GroupRozklad {

    // MARK: - State

    struct State: Equatable {

        var currentDay: Lesson.Day?
        var currentWeek: Lesson.Week = .first
        var currentLesson: CurrentLesson?
        var nextLessonId: Lesson.ID?

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

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClientable
        let rozkladClient: RozkladClient
        let currentDateClient: CurrentDateClient
    }

    // MARK: - Reducer

    static let coreReducer = Reducer<State, Action, Environment> { state, action, environment in
        enum SubscriberCancelId { }
        switch action {
        case .onAppear:
            state.isAppeared = true
            return Effect.merge(
                Effect(value: .updateCurrentDate),
                Effect.concatenate(
                    Effect(value: .updateLessons(environment.rozkladClient.lessons.subject.value)),
                    Effect(value: .scrollToNearest(state.needToScrollOnAppear)),
                    Effect(value: .binding(.set(\.$needToScrollOnAppear, false)))
                ),
                Effect.run { subscriber in
                    environment.rozkladClient.lessons.subject
                        .dropFirst()
                        .receive(on: DispatchQueue.main)
                        .sink { lessons in
                            subscriber.send(.updateLessons(lessons))
                        }
                },
                Effect.run { subscriber in
                    environment.currentDateClient.updated
                        .dropFirst()
                        .receive(on: DispatchQueue.main)
                        .sink { _ in
                            subscriber.send(.updateCurrentDate)
                        }
                }
            )
            .cancellable(id: SubscriberCancelId.self, cancelInFlight: true)

        case .onDisappear:
            state.isAppeared = false
            return .none

        case .updateCurrentDate:
            let oldCurrentLesson = state.currentLesson
            let oldNextLessonId = state.nextLessonId
            state.currentDay = environment.currentDateClient.currentDay.value
            state.currentWeek = environment.currentDateClient.currentWeek.value
            state.currentLesson = environment.currentDateClient.currentLesson.value
            state.nextLessonId = environment.currentDateClient.nextLessonId.value
            state.sections = [State.Section](
                lessons: state.lessons,
                currentLesson: state.currentLesson,
                nextLesson: state.nextLessonId
            )
            if oldCurrentLesson?.lessonId != state.currentLesson?.lessonId || oldNextLessonId != state.nextLessonId {
                if state.isAppeared {
                    return Effect(value: .scrollToNearest())
                        .delay(for: 0.2, scheduler: DispatchQueue.main)
                        .eraseToEffect()
                } else {
                    state.needToScrollOnAppear = true
                    return .none
                }

            } else {
                return .none
            }

        case let .updateLessons(lessons):
            state.groupName = environment.rozkladClient.state.group()?.name ?? "-"
            state.lessons = lessons
            state.sections = [State.Section](
                lessons: state.lessons,
                currentLesson: state.currentLesson,
                nextLesson: state.nextLessonId
            )
            return .none

        case let .scrollToNearest(needToScroll):
            if needToScroll {
                let scrollTo = state.currentLesson?.lessonId ?? state.nextLessonId
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
    .binding()

    static let reducer = Reducer<State, Action, Environment>.combine(
        LessonCell.reducer
            .forEach(
                state: \State.lessonCells,
                action: /Action.lessonCells,
                environment: { _ in LessonCell.Environment() }
            ),
        coreReducer
    )

}
