//
//  RozkladFlow.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture
import GroupPickerFeature
import Services
import RozkladFeature

@Reducer
struct RozkladFlow: Reducer {
    @ObservableState
    struct State: Equatable {
        var rozkladRoot: RozkladRootFlow.State
        // var path = StackState<Path.State>()
        
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
                print("!!! updateRozkladState")
                setRootRozkladState(from: rozkladState, state: &state)
                return .none
                
//            case let .rozkladRoot(.groupRozklad(.routeAction(.openDetails(lesson)))):
//                let lessonDetailsState = LessonDetails.State(
//                    lesson: lesson
//                )
//                state.path.append(.lessonDetails(lessonDetailsState))
//                return .none
                
            case .rozkladRoot(.groupPicker(.route(.done))):
                print("!!! DONE")

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
//            .forEach(\.path, action: \.path) {
//                Path()
//            }
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
            // case lessonDetails(LessonDetails.State)
        }
        
        public enum Action: Equatable {
            // case lessonDetails(LessonDetails.Action)
        }
        
        public var body: some ReducerOf<Self> {
            EmptyReducer()
//            Scope(state: \.lessonDetails, action: \.lessonDetails) {
//                LessonDetails()
//            }
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
        RozkladRootView(
            store: store.scope(
                state: \.rozkladRoot,
                action: \.rozkladRoot
            )
        )
//        NavigationStack(
//            path: $store.scope(state: \.path, action: \.path),
//            root: {
//                RozkladFlow.RozkladRootView(
//                    store: store.scope(
//                        state: \.rozkladRoot,
//                        action: \.rozkladRoot
//                    )
//                )
//            },
//            destination: { store in
//                switch store.withState({ $0 }) {
//                case .lessonDetails:
//                    if let store = store.scope(state: \.lessonDetails, action: \.lessonDetails) {
//                        LessonDetailsView(store: store)
//                    }
//                }
//            }
//        )
    }
}
