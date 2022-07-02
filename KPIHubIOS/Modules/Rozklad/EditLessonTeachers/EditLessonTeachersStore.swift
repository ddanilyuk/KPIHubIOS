//
//  EditLessonTeachersStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture

struct EditLessonTeachers {

    // MARK: - State

    struct State: Equatable {
        let lesson: Lesson
        let teachers: [String]
        var selected: [String]

        init(lesson: Lesson) {
            self.lesson = lesson
            self.teachers = lesson.lessonResponse.teachers ?? []
            self.selected = lesson.teachers ?? []
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case save
        case cancel

        case toggle(String)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case dismiss
        }
    }

    // MARK: - Environment

    struct Environment {
        let userDefaultsClient: UserDefaultsClientable
        let rozkladClient: RozkladClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .save:
            var newLesson = state.lesson
            newLesson.teachers = state.selected
            environment.rozkladClient.lessons.modify(.init(newLesson, commitChanges: true))
            return Effect(value: .routeAction(.dismiss))

        case .cancel:
            return Effect(value: .routeAction(.dismiss))

        case let .toggle(element):
            if let index = state.selected.firstIndex(of: element) {
                if state.selected.count > 1 {
                    state.selected.remove(at: index)
                }
            } else {
                state.selected.append(element)
            }
            return .none

        case .routeAction:
            return .none
        }
    }

}
