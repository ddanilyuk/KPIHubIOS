//
//  EditLessonNamesStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture

@Reducer
public struct EditLessonNames: Reducer {
    @ObservableState
    public struct State: Equatable {
        let lesson: Lesson
        let names: [String]
        var selected: [String]

        init(lesson: Lesson) {
            self.lesson = lesson
            self.names = lesson.lessonResponse.names
            self.selected = lesson.names
        }
    }

    public enum Action: Equatable, ViewAction {
        case view(View)
        
        public enum View: Equatable {
            case onAppear
            case saveButtonTapped
            case cancelButtonTapped
            case toggleLessonNameTapped(name: String)
        }
    }
    
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    @Dependency(\.analyticsService) var analyticsService
    @Dependency(\.dismiss) var dismiss

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                analyticsService.track(Event.LessonDetails.editNamesAppeared)
                return .none
                
            case .view(.saveButtonTapped):
                var newLesson = state.lesson
                newLesson.names = state.selected
                rozkladServiceLessons.modify(.init(newLesson, commitChanges: true))
                analyticsService.track(Event.LessonDetails.editNamesApply)
                return .run { _ in
                    await dismiss()
                }

            case .view(.cancelButtonTapped):
                return .run { _ in
                    await dismiss()
                }

            case let .view(.toggleLessonNameTapped(name)):
                if let index = state.selected.firstIndex(of: name) {
                    if state.selected.count > 1 {
                        state.selected.remove(at: index)
                    }
                } else {
                    state.selected.append(name)
                }
                return .none
            }
        }
    }
}
