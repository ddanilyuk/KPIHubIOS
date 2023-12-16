//
//  RozkladFeature.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture
import RozkladModels
import Services

@Reducer
public struct RozkladFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public let lessons: IdentifiedArrayOf<RozkladLessonModel>
        public var rows: IdentifiedArrayOf<RozkladLessonFeature.State>
        
        public init() {
            let mock = LessonResponse.mocked.map { Lesson(lessonResponse: $0) }
            let models = mock.map { RozkladLessonModel(lesson: $0) }
            lessons = IdentifiedArray(uniqueElements: models)
            
            let array = lessons.enumerated().map { index, lesson in
                RozkladLessonFeature.State(lesson: lesson, status: index == 1 ? .current : .idle)
            }
            rows = IdentifiedArray(uniqueElements: array)
        }
    }
    
    public enum Action: Equatable, ViewAction {
        case view(View)
        case local(Local)
        case output(Output)

        @CasePathable
        public enum View: Equatable {
            case profileButtonTapped
            case rows(IdentifiedActionOf<RozkladLessonFeature>)
        }
        
        public enum Local: Equatable {
            
        }
        
        public enum Output: Equatable {
            case openProfile
            case openLessonDetails(RozkladLessonModel)
        }
    }
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
            case let .local(localAction):
                return handleLocalAction(state: &state, action: localAction)
                
            case .output:
                return .none
            }
        }
        .forEach(\.rows, action: \.view.rows) {
            RozkladLessonFeature()
        }
    }
}

// MARK: - View
extension RozkladFeature {
    private func handleViewAction(state: inout State, action: Action.View) -> Effect<Action> {
        switch action {
        case let .rows(rowAction):
            return handleViewRowsAction(state: &state, action: rowAction)
            
        case .profileButtonTapped:
            return .send(.output(.openProfile))
        }
    }
    
    private func handleViewRowsAction(
        state: inout State,
        action: IdentifiedActionOf<RozkladLessonFeature>
    ) -> Effect<Action> {
        switch action {
        case let .element(id, .output(outputAction)):
            switch outputAction {
            case .openLesson:
                guard let model = state.lessons[id: id] else {
                    return .none
                }
                return .send(.output(.openLessonDetails(model)))
            }
            
        case .element:
            return .none
        }
    }
}

// MARK: - Local
extension RozkladFeature {
    private func handleLocalAction(state: inout State, action: Action.Local) -> Effect<Action> {
        return .none
    }
}
