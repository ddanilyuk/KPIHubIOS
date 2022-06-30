//
//  LessonDetailsStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

struct LessonDetails {

    // MARK: - State

    struct State: Equatable {

        var lesson: Lesson
        var mode: LessonMode = .default

        @BindableState var isEditing: Bool = false

        init(lesson: Lesson) {
            self.lesson = lesson
        }
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {

        case onAppear

        case updateCurrentDate
        case updateLesson(Lesson)

        case editNames
        case editTeachers

        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case editNames(_ lesson: Lesson)
            case editTeachers(_ lesson: Lesson)
        }
    }

    // MARK: - Environment

    struct Environment {
        let userDefaultsClient: UserDefaultsClientable
        let rozkladClient: RozkladClient
        let currentDateClient: CurrentDateClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        enum SubscriberCancelId { }
        switch action {
        case .onAppear:
            let lessonId = state.lesson.id
            return Effect.concatenate(
                Effect(value: .updateCurrentDate),
                Effect.run { subscriber in
                    environment.rozkladClient.lessons.subject
                        .receive(on: DispatchQueue.main)
                        .compactMap { $0[id: lessonId] }
                        .sink { lesson in
                            subscriber.send(.updateLesson(lesson))
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

        case .updateCurrentDate:
            let lessonId = state.lesson.id
            let currentLesson = environment.currentDateClient.currentLessonId.value
            let nextLessonId = environment.currentDateClient.nextLessonId.value

            if let currentLesson = currentLesson, lessonId == currentLesson.lessonId {
                state.mode = .current(currentLesson.percent)
            } else if lessonId == nextLessonId {
                state.mode = .next
            } else {
                state.mode = .default
            }
            return .none

        case let .updateLesson(lesson):
            state.lesson = lesson
            return .none

        case .editNames:
            guard state.isEditing else {
                return .none
            }
            return Effect(value: .routeAction(.editNames(state.lesson)))

        case .editTeachers:
            guard state.isEditing else {
                return .none
            }
            return Effect(value: .routeAction(.editTeachers(state.lesson)))

        case .binding:
            return .none

        case .routeAction:
            return .none
        }
    }
    .binding()

}
