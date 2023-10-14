//
//  RozkladScreenProvider.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

extension RozkladFlow {
    struct Path {}
}

extension RozkladFlow.Path: Reducer {
    enum State: Equatable {
        case lessonDetails(LessonDetails.State)
    }
    
    enum Action: Equatable {
        case lessonDetails(LessonDetails.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.lessonDetails, action: /Action.lessonDetails) {
            LessonDetails()
        }
    }
}
