//
//  RozkladFlow.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import IdentifiedCollections
import Foundation

@Reducer
public struct RozkladFlow: Reducer {
    @ObservableState
    public struct State: Equatable {
        var rozkladRoot: RozkladRoot.State
        // var path = StackState<Path.State>()

        init() {
            self.rozkladRoot = .groupPicker(GroupPickerFeature.State(mode: .rozkladTab))
        }
    }
    
    public enum Action: Equatable {
        case onSetup
        
        case updateRozkladState(RozkladServiceState.State)
        case rozkladRoot(RozkladRoot.Action)
        // case path(StackAction<Path.State, Path.Action>)
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
                
            case let .rozkladRoot(.groupRozklad(.routeAction(.openDetails(lesson)))):
                let lessonDetailsState = LessonDetails.State(
                    lesson: lesson
                )
                // state.path.append(.lessonDetails(lessonDetailsState))
                return .none
                
            case .rozkladRoot(.groupPicker(.route(.done))):
                rozkladServiceState.commit()
                rozkladServiceLessons.commit()
                return .none
                
//            case .path:
//                return .none
                
            case .rozkladRoot:
                return .none
            }
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.rozkladRoot, action: /Action.rozkladRoot) {
            RozkladRoot()
        }
        core
//            .forEach(\.path, action: /Action.path) {
//                Path()
//            }
    }
    
    private func setRootRozkladState(from rozkladState: RozkladServiceState.State, state: inout State) {
        switch rozkladState {
        case .selected:
            state.rozkladRoot = .groupRozklad(GroupRozklad.State())

        case .notSelected:
            state.rozkladRoot = .groupPicker(GroupPickerFeature.State(mode: .rozkladTab))
        }
    }
}
