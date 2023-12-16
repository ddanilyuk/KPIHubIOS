//
//  RozkladHeaderFeature.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture

@Reducer
public struct RozkladHeaderFeature: Reducer {
    @ObservableState
    public struct State: Identifiable, Equatable {
        let lesson: RozkladLessonModel
        
        public var id: RozkladLessonModel.ID {
            lesson.id
        }
        
        init(lesson: RozkladLessonModel) {
            self.lesson = lesson
        }
    }
    
    public enum Action: Equatable {
        
    }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
