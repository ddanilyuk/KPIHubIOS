//
//  RozkladLessonFeature.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture

// Supplementary features? Views?
@Reducer
public struct RozkladLessonFeature: Reducer {
    @ObservableState
    public struct State: Identifiable, Equatable {
        let lesson: RozkladLessonModel
        
        public var id: RozkladLessonModel.ID {
            lesson.id
        }
        
        init(lesson: RozkladLessonModel) {
            self.lesson = lesson
        }
    }
    
    public enum Action: Equatable {
        
    }
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
}

import SwiftUI

public struct RozkladLessonView: View {
    public let store: StoreOf<RozkladLessonFeature>
    
    public init(store: StoreOf<RozkladLessonFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            Text(store.lesson.name)
                .fontWeight(.bold)
            Text(store.lesson.teacher)
        }
    }
}

public struct RozkladLessonExtendedView: View {
    public let store: StoreOf<RozkladLessonFeature>
    
    public init(store: StoreOf<RozkladLessonFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            Text(store.lesson.id.description)
            Text(store.lesson.name)
                .fontWeight(.bold)
            Text(store.lesson.teacher)
        }
        .padding()
        .background(Color.orange.opacity(0.5))
    }
}
