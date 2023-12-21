//
//  EditLessonNamesFeature.swift
//
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture
import RozkladModels
import RozkladServices
import GeneralServices

@Reducer
public struct EditLessonNamesFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public let lesson: RozkladLessonModel
        public let names: [String]
        public var selected: [String]

        public init(lesson: RozkladLessonModel) {
            self.lesson = lesson
            self.names = lesson.names
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
    
    public init() { }

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
