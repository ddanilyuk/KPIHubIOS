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

        init(lesson: Lesson) {
            self.lesson = lesson
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear

        case updateLesson(Lesson)

        case editNames
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case editNames(_ names: [String], _ selected: [String])
        }
    }

    // MARK: - Environment

    struct Environment {
        let userDefaultsClient: UserDefaultsClient
        let rozkladClient: RozkladClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onAppear:
            let lessonId = state.lesson.id
            return Effect.run { subscriber in
                environment.rozkladClient.lessons
                    .compactMap { $0[id: lessonId] }
                    .sink { lesson in
                        subscriber.send(.updateLesson(lesson))
                    }
            }

        case let .updateLesson(lesson):
            state.lesson = lesson
            return .none

        case .editNames:
            let allNames = state.lesson.lessonResponse.names
            let selected = state.lesson.names
            return Effect(value: .routeAction(.editNames(allNames, selected)))

        case .routeAction:
            return .none
        }
    }

}
