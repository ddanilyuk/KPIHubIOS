//
//  EditLessonTeachersStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture

struct EditLessonTeachers: ReducerProtocol {

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
    
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons

    // MARK: - Reducer
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .save:
                var newLesson = state.lesson
                newLesson.teachers = state.selected
                rozkladClientLessons.modify(.init(newLesson, commitChanges: true))
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

}
