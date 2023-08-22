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
        case editLessonNames(EditLessonNames.State)
        case editLessonTeachers(EditLessonTeachers.State)
    }
    
    enum Action: Equatable {
        case lessonDetails(LessonDetails.Action)
        case editLessonNames(EditLessonNames.Action)
        case editLessonTeachers(EditLessonTeachers.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.lessonDetails, action: /Action.lessonDetails) {
            LessonDetails()
        }
        Scope(state: /State.editLessonNames, action: /Action.editLessonNames) {
            EditLessonNames()
        }
        Scope(state: /State.editLessonTeachers, action: /Action.editLessonTeachers) {
            EditLessonTeachers()
        }
    }
}
