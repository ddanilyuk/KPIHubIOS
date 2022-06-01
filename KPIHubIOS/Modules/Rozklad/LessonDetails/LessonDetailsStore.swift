//
//  LessonDetailsStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

struct LessonDetails {

    // MARK: - State

    struct State: Equatable {

        let names: [String]
        let teachers: [Teacher]
        let locations: [String]

        let week: Lesson.Week
        let day: Lesson.Day
        let position: Lesson.Position

        init(lesson: Lesson) {
            self.names = lesson.names
            self.teachers = lesson.teachers ?? []
            self.locations = lesson.locations ?? []

            self.week = lesson.week
            self.day = lesson.day
            self.position = lesson.position
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case start
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .start:
            return .none
        }
    }

}
