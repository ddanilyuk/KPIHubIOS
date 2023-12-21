//
//  LessonCellStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 31.05.2022.
//

import ComposableArchitecture
import Foundation
import GeneralServices

public struct LessonCell: Reducer {
    public struct State: Equatable, Identifiable {
        let lesson: Lesson
        var mode: LessonMode = .default
        
        public var id: Lesson.ID {
            lesson.id
        }
    }
    
    public enum Action: Equatable {
        case onTap
        case onAppear
        case onDisappear
    }
    
    public var body: some ReducerOf<Self> {
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
