//
//  EditLessonNamesStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture

struct EditLessonNames: Reducer {

    // MARK: - State

    struct State: Equatable {
        let lesson: Lesson
        let names: [String]
        var selected: [String]

        init(lesson: Lesson) {
            self.lesson = lesson
            self.names = lesson.lessonResponse.names
            self.selected = lesson.names
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
        case save
        case cancel

        case toggle(String)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case dismiss
        }
    }
    
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.analyticsService) var analyticsService
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                analyticsService.track(Event.LessonDetails.editNamesAppeared)
                return .none
                
            case .save:
                var newLesson = state.lesson
                newLesson.names = state.selected
                rozkladClientLessons.modify(.init(newLesson, commitChanges: true))
                analyticsService.track(Event.LessonDetails.editNamesApply)
                return .send(.routeAction(.dismiss))

            case .cancel:
                return .send(.routeAction(.dismiss))

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
