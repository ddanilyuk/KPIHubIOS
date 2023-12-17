//
//  EditLessonTeachersStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture
import Services
import RozkladModels
import RozkladServices

@Reducer
public struct EditLessonTeachers: Reducer {
    @ObservableState
    public struct State: Equatable {
        let lesson: RozkladLessonModel
        let teachers: [String]
        var selected: [String]

        init(lesson: RozkladLessonModel) {
            self.lesson = lesson
            self.teachers = lesson.teachers ?? []
            self.selected = lesson.teachers ?? []
        }
    }
    
    public enum Action: Equatable, ViewAction {
        case view(View)
        
        public enum View: Equatable {
            case onAppear
            case saveButtonTapped
            case cancelButtonTapped
            case toggleLessonTeacherTapped(name: String)
        }
    }
    
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    @Dependency(\.analyticsService) var analyticsService
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
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
                return .run { _ in
                    await dismiss()
                }

            case .view(.cancelButtonTapped):
                return .run { _ in
                    await dismiss()
                }

            case let .view(.toggleLessonTeacherTapped(element)):
                if let index = state.selected.firstIndex(of: element) {
                    if state.selected.count > 1 {
                        state.selected.remove(at: index)
                    }
                } else {
                    state.selected.append(element)
                }
                return .none
            }
        }
    }
}
