//
//  RozkladFeature.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture
import Services

public struct RozkladLessonModel: Identifiable, Equatable {
    public let id: Int
    public let name: String
    public let teacher: String
    
    public init(lesson: Lesson) {
        self.id = lesson.id
        self.name = lesson.names.first ?? "-"
        self.teacher = lesson.teachers?.first ?? "-"
    }
}

@Reducer
public struct RozkladFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        let lessons: IdentifiedArrayOf<RozkladLessonModel>
        var rows: IdentifiedArrayOf<RozkladLessonFeature.State>
        
        public init() {
            let mock = LessonResponse.mocked.map { Lesson(lessonResponse: $0) }
            let models = mock.map { RozkladLessonModel(lesson: $0) }
            lessons = IdentifiedArray(uniqueElements: models)
            
            let array = lessons.map { RozkladLessonFeature.State(lesson: $0) }
            rows = IdentifiedArray(uniqueElements: array)
        }
    }
    
    public enum Action: Equatable, ViewAction {
        case view(View)
        case local(Local)
        case output(Output)

        case rows(IdentifiedActionOf<RozkladLessonFeature>)

        public enum View: Equatable {
        }
        
        public enum Local: Equatable {
            
        }
        
        public enum Output: Equatable {
            
        }
    }
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .rows:
                return .none
                
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
            case let .local(localAction):
                return handleLocalAction(state: &state, action: localAction)
                
            case .output:
                return .none
            }
        }
        .forEach(\.rows, action: \.rows) {
            RozkladLessonFeature()
        }
    }
}

// MARK: - View
extension RozkladFeature {
    private func handleViewAction(state: inout State, action: Action.View) -> Effect<Action> {
        return .none
    }
}

// MARK: - Local
extension RozkladFeature {
    private func handleLocalAction(state: inout State, action: Action.Local) -> Effect<Action> {
        return .none
    }
}

import SwiftUI

@ViewAction(for: RozkladFeature.self)
public struct RozkladView<Cell: View>: View {
    public let store: StoreOf<RozkladFeature>
    public var cell: (StoreOf<RozkladLessonFeature>) -> Cell
    
    public init(
        store: StoreOf<RozkladFeature>,
        @ViewBuilder cell: @escaping (StoreOf<RozkladLessonFeature>) -> Cell
    ) {
        self.store = store
        self.cell = cell
    }
    
    public var body: some View {
        ScrollView {
            ForEach(store.scope(state: \.rows, action: \.rows)) { childStore in
                cell(childStore)
            }
        }
    }
}
