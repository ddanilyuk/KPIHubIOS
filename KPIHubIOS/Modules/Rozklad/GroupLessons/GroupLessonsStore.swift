//
//  GroupLessonsStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import IdentifiedCollections
import ComposableArchitecture
import Foundation

struct GroupLessons {

    // MARK: - State

    struct State: Equatable {
        
        var scheduleDays: [ScheduleDay]
        var lessonCells: [IdentifiedArrayOf<LessonCell.State>]
        var test: IdentifiedArrayOf<LessonCell.State>

        init() {
            scheduleDays = [ScheduleDay](lessons: Lesson.mocked)
            lessonCells = scheduleDays.map { day in
                IdentifiedArrayOf(uniqueElements: day.lessons.map { LessonCell.State(lesson: $0) })
            }
            test = IdentifiedArrayOf(uniqueElements: scheduleDays[0].lessons.map { LessonCell.State(lesson: $0) })
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case start
        case lessonCells(id: Lesson.ID, action: LessonCell.Action)
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let coreReducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .start:
            return .none

        case .lessonCells:
            return .none
        }
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        LessonCell.reducer
            .forEach(
                state: \State.test,
                action: /Action.lessonCells,
                environment: { _ in LessonCell.Environment() }
            ),
        coreReducer
    )

}
