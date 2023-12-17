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
        @Presents var destination: Destination.State?
        var path = StackState<Path.State>()
        
        init() {
            self.rozkladRoot = .groupPicker(GroupPickerFeature.State(mode: .rozkladTab))
        }
    }
    
    enum Action: Equatable {
        case onSetup
        
        case destination(PresentationAction<Destination.Action>)
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
                
            case let .destination(destinationAction):
                return handleDestinationAction(state: &state, action: destinationAction)
                
            case let .updateRozkladState(rozkladState):
                setRootRozkladState(from: rozkladState, state: &state)
                return .none
                
            case let .rozkladRoot(rozkladRootAction):
                return handleRozkladRoot(state: &state, action: rozkladRootAction)
                                
            case .path:
                return .none
            }
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.rozkladRoot, action: \.rozkladRoot) {
            RozkladRootFlow()
        }
        core
            .ifLet(\.$destination, action: \.destination) {
                Destination()
            }
            .forEach(\.path, action: \.path) {
                Path()
            }
    }
    
    private func handleDestinationAction(state: inout State, action: PresentationAction<Destination.Action>) -> Effect<Action> {
        switch action {
        case .presented(.profile):
            return .none
            
        case .presented:
            return .none
            
        case .dismiss:
            return .none
        }
    }
    
    private func handleRozkladRoot(state: inout State, action: RozkladRootFlow.Action) -> Effect<Action> {
        switch action {
        case let .groupPicker(groupPickerAction):
            return handleGroupPickerAction(state: &state, action: groupPickerAction)
            
        case let .groupRozklad(groupRozkladAction):
            return handleGroupRozkladAction(state: &state, action: groupRozkladAction)
        }
    }
    
    private func handleGroupPickerAction(state: inout State, action: GroupPickerFeature.Action) -> Effect<Action> {
        switch action {
        case let .route(route):
            switch route {
            case .done:
                rozkladServiceState.commit()
                rozkladServiceLessons.commit()
                return .none
            }
        default:
            return .none
        }
    }
    
    private func handleGroupRozkladAction(state: inout State, action: RozkladFeature.Action) -> Effect<Action> {
        switch action {
        case let .output(outputAction):
            switch outputAction {
            case let .openLessonDetails(lesson):
                let lessonDetailsState = LessonDetailsFeature.State(
                    lesson: lesson
                )
                state.path.append(.lessonDetails(lessonDetailsState))
                return .none
                
            case .openProfile:
                state.destination = .profile(ProfileFlow.State())
                return .none
            }
            
        default:
            return .none
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
    
    @Reducer
    public struct Destination: Reducer {
        @ObservableState
        public enum State: Equatable {
            case profile(ProfileFlow.State)
        }
        
        public enum Action: Equatable {
            case profile(ProfileFlow.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.profile, action: \.profile) {
                ProfileFlow()
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
                .sheet(
                    item: $store.scope(
                        state: \.destination?.profile,
                        action: \.destination.profile
                    )
                ) { store in
                    ProfileFlowView(store: store)
                }
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
