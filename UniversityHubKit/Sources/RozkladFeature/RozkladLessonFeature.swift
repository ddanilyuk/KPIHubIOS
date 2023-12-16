//
//  RozkladLessonFeature.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture

@Reducer
public struct RozkladLessonFeature: Reducer {
    @ObservableState
    public struct State: Identifiable, Equatable {
        let lesson: RozkladLessonModel
        
        public var id: RozkladLessonModel.ID {
            lesson.id
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
