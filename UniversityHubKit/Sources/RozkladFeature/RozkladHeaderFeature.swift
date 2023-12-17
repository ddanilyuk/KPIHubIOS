//
//  RozkladHeaderFeature.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture
import RozkladModels

@Reducer
public struct RozkladHeaderFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        var currentLessonDay: LessonDay
        
        init(currentLessonDay: LessonDay) {
            self.currentLessonDay = currentLessonDay
        }
    }
    
    public enum Action: Equatable {
        
    }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}
