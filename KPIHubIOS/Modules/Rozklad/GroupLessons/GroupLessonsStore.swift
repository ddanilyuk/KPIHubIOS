//
//  GroupLessonsStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

struct GroupLessons {

    // MARK: - State

    struct State: Equatable {
        var scheduleDays: [ScheduleDay]

        init() {
            self.scheduleDays = .init(lessons: Lesson.mocked)
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
