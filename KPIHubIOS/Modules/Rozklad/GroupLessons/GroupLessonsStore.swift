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

        init() {
            scheduleDays = [ScheduleDay](lessons: Lesson.mocked)
            lessonCells = scheduleDays.map { day in
                IdentifiedArrayOf(uniqueElements: day.lessons.map { LessonCell.State(lesson: $0) })
            }
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
        case lessonCells(id: Lesson.ID, action: LessonCell.Action)
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let coreReducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .onAppear:
            return .none

        case .lessonCells:
            return .none
        }
    }

    static let reducer = Reducer<State, Action, Environment>.combine(
        Reducer<State, Action, Environment>.combine(
            (0..<12).map({ index in
                LessonCell.reducer
                    .forEach(
                        state: \State.lessonCells[index],
                        action: /Action.lessonCells,
                        environment: { _ in LessonCell.Environment() }
                    )
            })
        ),
        coreReducer
    )

}
