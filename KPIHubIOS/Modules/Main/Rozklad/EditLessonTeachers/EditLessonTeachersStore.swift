//
//  EditLessonTeachersStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture

struct EditLessonTeachers: Reducer {
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
    
    enum Action: Equatable {
        case view(View)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case dismiss
        }
        
        enum View: Equatable {
            case onAppear
            case saveButtonTapped
            case cancelButtonTapped
            case toggleLessonTeacherTapped(name: String)
        }
    }
    
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    @Dependency(\.analyticsService) var analyticsService

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                analyticsService.track(Event.LessonDetails.editTeachersAppeared)
                return .none

            case .view(.saveButtonTapped):
                var newLesson = state.lesson
                newLesson.teachers = state.selected
                rozkladServiceLessons.modify(.init(newLesson, commitChanges: true))
                analyticsService.track(Event.LessonDetails.editTeachersApply)
                return .send(.routeAction(.dismiss))

            case .view(.cancelButtonTapped):
                return .send(.routeAction(.dismiss))

            case let .view(.toggleLessonTeacherTapped(element)):
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
