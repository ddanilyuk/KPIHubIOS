//
//  LessonCellStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 31.05.2022.
//

import ComposableArchitecture

struct LessonCell {

    // MARK: - State

    struct State: Equatable, Identifiable, Hashable {
        let lesson: Lesson

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        var id: Lesson.ID {
            return lesson.id
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onTap
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .onTap:
            return .none
        }
    }

}
