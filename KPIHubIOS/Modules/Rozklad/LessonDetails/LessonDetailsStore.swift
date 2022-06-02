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

        var lesson: Lesson

//        var names: String {
//            re
//        }

        init(lesson: Lesson) {
            self.lesson = lesson
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case start
    }

    // MARK: - Environment

    struct Environment {
        let userDefaultsClient: UserDefaultsClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .start:
            return .none
        }
    }

}
