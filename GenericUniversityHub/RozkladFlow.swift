//
//  RozkladFlow.swift
//  GenericUniversityHub
//
//  Created by Denys Danyliuk on 17.12.2023.
//

import ComposableArchitecture
import GroupPickerFeature
import Services
import RozkladFeature
import LessonDetailsFeature

@Reducer
struct RozkladFlow: Reducer {
    @ObservableState
    struct State: Equatable {
        var rozkladRoot: RozkladRootFlow.State
        var path = StackState<Path.State>()
        
        init() {
            self.rozkladRoot = .groupPicker(GroupPickerFeature.State(mode: .rozkladTab))
        }
    }
    
    enum Action: Equatable {
        case onSetup
        
        case updateRozkladState(RozkladServiceState.State)
        case rozkladRoot(RozkladRootFlow.Action)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    @Dependency(\.rozkladServiceState) var rozkladServiceState
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
        
    var core: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onSetup:
                setRootRozkladState(from: rozkladServiceState.currentState(), state: &state)
                return .run { send in
                    for await state in rozkladServiceState.stateStream().dropFirst() {
                        await send(.updateRozkladState(state))
                    }
                }
                
            case let .updateRozkladState(rozkladState):
                setRootRozkladState(from: rozkladState, state: &state)
                return .none
                
            case let .rozkladRoot(.groupRozklad(.output(.openLessonDetails(lesson)))):
                let lessonDetailsState = LessonDetailsFeature.State(
                    lesson: lesson
                )
                state.path.append(.lessonDetails(lessonDetailsState))
                return .none
                
            case .rozkladRoot(.groupPicker(.route(.done))):
                rozkladServiceState.commit()
                rozkladServiceLessons.commit()
                return .none
                
            case .path:
                return .none
                
            case .rozkladRoot:
                return .none
            }
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.rozkladRoot, action: \.rozkladRoot) {
            RozkladRootFlow()
        }
        core
            .forEach(\.path, action: \.path) {
                Path()
            }
    }
    
    private func setRootRozkladState(from rozkladState: RozkladServiceState.State, state: inout State) {
        switch rozkladState {
        case .selected:
            state.rozkladRoot = .groupRozklad(RozkladFeature.State())

        case .notSelected:
            state.rozkladRoot = .groupPicker(GroupPickerFeature.State(mode: .rozkladTab))
        }
    }
}

// MARK: New file

import ComposableArchitecture

extension RozkladFlow {
    @Reducer
    public struct Path: Reducer {
        @ObservableState
        public enum State: Equatable {
            case lessonDetails(LessonDetailsFeature.State)
        }
        
        public enum Action: Equatable {
            case lessonDetails(LessonDetailsFeature.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.lessonDetails, action: \.lessonDetails) {
                LessonDetailsFeature()
            }
        }
    }
}

import SwiftUI

struct RozkladFlowView: View {
    @Bindable var store: StoreOf<RozkladFlow>
    
    init(store: StoreOf<RozkladFlow>) {
        self.store = store
    }
    
    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path),
            root: {
                RozkladRootView(
                    store: store.scope(
                        state: \.rozkladRoot,
                        action: \.rozkladRoot
                    )
                )
            },
            destination: { store in
                switch store.withState({ $0 }) {
                case .lessonDetails:
                    EmptyView()
//                    if let store = store.scope(state: \.lessonDetails, action: \.lessonDetails) {
//                        LessonDetailsView(store: store)
//                    }
                }
            }
        )
    }
}

@Reducer
struct RozkladRootFlow: Reducer {
    @ObservableState
    enum State: Equatable {
        case groupRozklad(RozkladFeature.State)
        case groupPicker(GroupPickerFeature.State)
    }
    
    enum Action: Equatable {
        case groupRozklad(RozkladFeature.Action)
        case groupPicker(GroupPickerFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.groupRozklad, action: \.groupRozklad) {
            RozkladFeature()
        }
        Scope(state: \.groupPicker, action: \.groupPicker) {
            GroupPickerFeature()
        }
    }
}

import SwiftUI

struct RozkladRootView: View {
    private let store: StoreOf<RozkladRootFlow>
    
    init(store: StoreOf<RozkladRootFlow>) {
        self.store = store
    }
    
    var body: some View {
        switch store.withState({ $0 }) {
        case .groupRozklad:
            if let childStore = store.scope(state: \.groupRozklad, action: \.groupRozklad) {
                RozkladView(store: childStore) { cellStore in
                    RozkladLessonView(store: cellStore)
                }
            }
            
        case .groupPicker:
            if let childStore = store.scope(state: \.groupPicker, action: \.groupPicker) {
                GroupPickerView(store: childStore)
            }
        }
    }
}
