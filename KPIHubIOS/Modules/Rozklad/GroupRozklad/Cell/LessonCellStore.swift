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
        
        var showTeachers: Bool {
            !lesson.isTeachersEmpty
        }
        var showLocationsAndType: Bool {
            !lesson.isTypeEmpty || !lesson.isLocationsEmpty
        }
        var showLocations: Bool {
            !lesson.isLocationsEmpty
        }
        var showType: Bool {
            !lesson.isTypeEmpty
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

    // MARK: - Reducer
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
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
