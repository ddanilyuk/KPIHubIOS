//
//  LessonDetailsStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import Foundation

struct LessonDetails {

    // MARK: - State

    struct State: Equatable {

        var lesson: Lesson
        var mode: LessonMode = .default

        @BindableState var isEditing: Bool = false
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
        enum SubscriberCancelID { }
        switch action {
        case .onAppear:
            let lessonID = state.lesson.id
            return Effect.merge(
                Effect(value: .updateCurrentDate),
                Effect.run { subscriber in
                    environment.rozkladClient.lessons.subject
                        .compactMap { $0[id: lessonID] }
                        .receive(on: DispatchQueue.main)
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
            .cancellable(id: SubscriberCancelID.self, cancelInFlight: true)

        case .updateCurrentDate:
            let lessonID = state.lesson.id
            let currentLesson = environment.currentDateClient.currentLesson.value
            let nextLessonID = environment.currentDateClient.nextLessonID.value

            if let currentLesson = currentLesson, lessonID == currentLesson.lessonID {
                state.mode = .current(currentLesson.percent)
            } else if lessonID == nextLessonID {
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
