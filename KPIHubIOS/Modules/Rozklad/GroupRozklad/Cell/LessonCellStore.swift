//
//  LessonCellStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 31.05.2022.
//

import ComposableArchitecture
import CoreGraphics

struct LessonCell {

    // MARK: - State

    struct State: Equatable, Identifiable, Hashable {
        let lesson: Lesson
        var mode: LessonMode = .default

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
        case onAppear
        case onDisappear
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        enum SubscriberCancelId {}
        switch action {
        case .onTap:
            return .none

        case .onAppear:
            return .none

        case .onDisappear:
            return .cancel(id: SubscriberCancelId.self)

        }
    }

}
