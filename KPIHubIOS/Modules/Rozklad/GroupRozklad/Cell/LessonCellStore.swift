//
//  LessonCellStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 31.05.2022.
//

import ComposableArchitecture
import CoreGraphics

struct LessonCell: ReducerProtocol {

    // MARK: - State

    struct State: Equatable, Identifiable {
        let lesson: Lesson
        var mode: LessonMode = .default

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

    // MARK: - Reducer
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onTap:
                return .none

            case .onAppear:
                return .none

            case .onDisappear:
                return .none
            }
        }
    }

}
