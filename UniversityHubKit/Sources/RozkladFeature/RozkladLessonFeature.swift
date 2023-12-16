//
//  RozkladLessonFeature.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture

@Reducer
public struct RozkladLessonFeature: Reducer {
    @ObservableState
    public struct State: Identifiable, Equatable {
        public let lesson: RozkladLessonModel
        public let status: Status
        
        public enum Status {
            case idle
            case current
            case next
        }
        
        public var id: RozkladLessonModel.ID {
            lesson.id
        }
        
        public init(lesson: RozkladLessonModel, status: Status) {
            self.lesson = lesson
            self.status = status
        }
    }
    
    public enum Action: Equatable, ViewAction {
        case view(View)
        case output(Output)
        
        public enum View: Equatable {
            case onTap
        }
        
        public enum Output: Equatable {
            case openLesson
        }
    }
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onTap):
                return .send(.output(.openLesson))
                
            case .output:
                return .none
            }
        }
    }
}
