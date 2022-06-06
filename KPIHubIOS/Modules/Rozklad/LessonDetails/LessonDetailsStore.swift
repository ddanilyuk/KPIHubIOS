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

        @BindableState var isEditing: Bool = false

        init(lesson: Lesson) {
            self.lesson = lesson
        }
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {

        case onAppear

        case updateLesson(Lesson)

        case edit
        case editingDone

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
        let userDefaultsClient: UserDefaultsClient
        let rozkladClient: RozkladClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onAppear:
            let lessonId = state.lesson.id
            return Effect.run { subscriber in
                environment.rozkladClient.lessonsSubject
                    .compactMap { $0[id: lessonId] }
                    .sink { lesson in
                        subscriber.send(.updateLesson(lesson))
                    }
            }

        case let .updateLesson(lesson):
            state.lesson = lesson
            return .none

        case .edit:
            return .none
            return Effect(value: .routeAction(.editNames(state.lesson)))

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

        case .editingDone:
            state.isEditing = false
            return .none

        case .binding:
            return .none

        case .routeAction:
            return .none
        }
    }
    .binding()

}
