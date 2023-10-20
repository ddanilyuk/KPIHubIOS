//
//  LessonCellStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 31.05.2022.
//

import ComposableArchitecture
import CoreGraphics

struct LessonCell: Reducer {
    struct State: Equatable, Identifiable {
        let lesson: Lesson
        var mode: LessonMode = .default
        
        var id: Lesson.ID {
            lesson.id
        }
    }
    
    enum Action: Equatable {
        case onTap
        case onAppear
        case onDisappear
    }
    
    var body: some ReducerOf<Self> {
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
