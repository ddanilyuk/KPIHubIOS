//
//  RozkladRowProviderFeature.swift
//
//
//  Created by Denys Danyliuk on 17.12.2023.
//

import ComposableArchitecture
import RozkladModels

@Reducer
public struct RozkladRowProviderFeature: Reducer {
    @ObservableState
    public enum State: Equatable, Identifiable {
        case sectionHeader(RozkladSectionHeaderFeature.State)
        case rozkladLesson(RozkladLessonFeature.State)
        
        public var id: String {
            switch self {
            case let .sectionHeader(state):
                return "\(state.lessonDay.day)-\(state.lessonDay.week)"
                
            case let .rozkladLesson(state):
                return state.id.stringValue
            }
        }
        
        public var lessonDay: LessonDay {
            switch self {
            case let .rozkladLesson(state):
                return LessonDay(day: state.lesson.day, week: state.lesson.week)
                
            case let .sectionHeader(state):
                return state.lessonDay
            }
        }        
    }
    
    public enum Action {
        case sectionHeader(RozkladSectionHeaderFeature.Action)
        case rozkladLesson(RozkladLessonFeature.Action)
    }
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.sectionHeader, action: \.sectionHeader) {
            RozkladSectionHeaderFeature()
        }
        Scope(state: \.rozkladLesson, action: \.rozkladLesson) {
            RozkladLessonFeature()
        }
    }
}

@Reducer
public struct RozkladSectionHeaderFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public let lessonDay: LessonDay
        
        public init(day: Int, week: Int) {
            self.lessonDay = LessonDay(day: day, week: week)
        }
    }
    
    public enum Action { }
    
    public init() { }

    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

import SwiftUI

public struct RozkladRowProviderView<Cell: View>: View {
    public let store: StoreOf<RozkladRowProviderFeature>
    public var cell: (StoreOf<RozkladLessonFeature>) -> Cell
    
    public init(store: StoreOf<RozkladRowProviderFeature>, cell: @escaping (StoreOf<RozkladLessonFeature>) -> Cell) {
        self.store = store
        self.cell = cell
    }

    public var body: some View {
        switch store.withState({ $0 }) {
        case .rozkladLesson:
            if let childStore = store.scope(state: \.rozkladLesson, action: \.rozkladLesson) {
                cell(childStore)
            }
            
        case .sectionHeader:
            if let childStore = store.scope(state: \.sectionHeader, action: \.sectionHeader) {
                RozkladSectionHeaderView(store: childStore)
            }
        }
    }
}

public struct RozkladSectionHeaderView: View {
    public let store: StoreOf<RozkladSectionHeaderFeature>
    
    public init(store: StoreOf<RozkladSectionHeaderFeature>) {
        self.store = store
    }
    
    public var body: some View {
        Text("Day: \(store.lessonDay.day) | Week: \(store.lessonDay.week)")
    }
}
