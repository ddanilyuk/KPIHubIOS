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
    public var names: [String]
    public var teachers: [String]?
    public var locations: [String]?
    public var type: String

    public init(lesson: Lesson) {
        self.id = lesson.id
        self.names = lesson.names
        self.teachers = lesson.teachers
        self.locations = lesson.locations
        self.type = lesson.type
    }
}

@Reducer
public struct RozkladFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public let lessons: IdentifiedArrayOf<RozkladLessonModel>
        public var rows: IdentifiedArrayOf<RozkladLessonFeature.State>
        
        public init() {
            let mock = LessonResponse.mocked.map { Lesson(lessonResponse: $0) }
            let models = mock.map { RozkladLessonModel(lesson: $0) }
            lessons = IdentifiedArray(uniqueElements: models)
            
            let array = lessons.enumerated().map { index, lesson in
                RozkladLessonFeature.State(lesson: lesson, status: index == 1 ? .current : .idle)
            }
            rows = IdentifiedArray(uniqueElements: array)
        }
    }
    
    public enum Action: Equatable, ViewAction {
        case view(View)
        case local(Local)
        case output(Output)

        @CasePathable
        public enum View: Equatable {
            case rows(IdentifiedActionOf<RozkladLessonFeature>)
        }
        
        public enum Local: Equatable {
            
        }
        
        public enum Output: Equatable {
            case openLessonDetails(Int)
        }
    }
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
            case let .local(localAction):
                return handleLocalAction(state: &state, action: localAction)
                
            case .output:
                return .none
            }
        }
        .forEach(\.rows, action: \.view.rows) {
            RozkladLessonFeature()
        }
    }
}

// MARK: - View
extension RozkladFeature {
    private func handleViewAction(state: inout State, action: Action.View) -> Effect<Action> {
        switch action {
        case let .rows(rowAction):
            return handleViewRowsAction(state: &state, action: rowAction)
        }
    }
    
    private func handleViewRowsAction(
        state: inout State,
        action: IdentifiedActionOf<RozkladLessonFeature>
    ) -> Effect<Action> {
        switch action {
        case let .element(id, .output(outputAction)):
            switch outputAction {
            case .openLesson:
                return .send(.output(.openLessonDetails(id)))
            }
            
        case .element:
            return .none
        }
    }
}

// MARK: - Local
extension RozkladFeature {
    private func handleLocalAction(state: inout State, action: Action.Local) -> Effect<Action> {
        return .none
    }
}

import SwiftUI
import DesignKit

@ViewAction(for: RozkladFeature.self)
public struct RozkladView<Cell: View>: View {
    public let store: StoreOf<RozkladFeature>
    public var cell: (StoreOf<RozkladLessonFeature>) -> Cell
    
    @Environment(\.designKit) private var designKit
    
    public init(
        store: StoreOf<RozkladFeature>,
        @ViewBuilder cell: @escaping (StoreOf<RozkladLessonFeature>) -> Cell
    ) {
        self.store = store
        self.cell = cell
    }
    
    public var body: some View {
        ScrollView {
            ForEach(store.scope(state: \.rows, action: \.view.rows)) { childStore in
                cell(childStore)
            }
        }
        .background(designKit.backgroundColor)
    }
}
