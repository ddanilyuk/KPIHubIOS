//
//  RozkladStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import IdentifiedCollections
import Foundation

struct RozkladRoot: Reducer {
    enum State: Equatable {
        case groupRozklad(GroupRozklad.State)
        case groupPicker(GroupPickerFeature.State)
    }
    
    enum Action: Equatable {
        case groupRozklad(GroupRozklad.Action)
        case groupPicker(GroupPickerFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: /State.groupRozklad, action: /Action.groupRozklad) {
            GroupRozklad()
        }
        Scope(state: /State.groupPicker, action: /Action.groupPicker) {
            GroupPickerFeature()
        }
    }
}

import SwiftUI
struct RozkladRootView: View {
    let store: StoreOf<RozkladRoot>
    
    var body: some View {
        SwitchStore(store) { state in
            switch state {
            case .groupRozklad:
                CaseLet(
                    /RozkladRoot.State.groupRozklad,
                    action: RozkladRoot.Action.groupRozklad,
                    then: GroupRozkladView.init(store:)
                )
            case .groupPicker:
                CaseLet(
                    /RozkladRoot.State.groupPicker,
                    action: RozkladRoot.Action.groupPicker,
                    then: GroupPickerView.init(store:)
                )
            }
        }
    }
}

struct Rozklad: Reducer {

    // MARK: - State

    struct State: Equatable {
        var rozkladRoot: RozkladRoot.State
        var path = StackState<Path.State>()

        init() {
            self.rozkladRoot = .groupPicker(GroupPickerFeature.State(mode: .rozkladTab))
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onSetup
        
        case updateRozkladState(RozkladClientState.State)
        case rozkladRoot(RozkladRoot.Action)
        case path(StackAction<Path.State, Path.Action>)
    }

    // MARK: - Environment
    
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.analyticsClient) var analyticsClient

    // MARK: - Reducer
    
    var core: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .onSetup:
                setRootRozkladState(from: rozkladClientState.subject.value, state: &state)
                return Effect.run { subscriber in
                    rozkladClientState.subject
                        .dropFirst()
                        .removeDuplicates()
                        .receive(on: DispatchQueue.main)
                        .sink { state in
                            subscriber.send(.updateRozkladState(state))
                        }
                }
                
            case let .updateRozkladState(rozkladState):
                setRootRozkladState(from: rozkladState, state: &state)
                return .none
                
            case let .rozkladRoot(.groupRozklad(.routeAction(.openDetails(lesson)))):
                let lessonDetailsState = LessonDetails.State(
                    lesson: lesson
                )
                state.path.append(.lessonDetails(lessonDetailsState))
                return .none
                
            case .rozkladRoot(.groupPicker(.route(.done))):
                rozkladClientState.commit()
                rozkladClientLessons.commit()
                return .none

            case let .path(.element(_, .lessonDetails(.routeAction(.editNames(lesson))))):
                // TODO: Use another approach
                let editLessonNamesState = EditLessonNames.State(lesson: lesson)
                state.path.append(.editLessonNames(editLessonNamesState))
                return .none

            case let .path(.element(_, .lessonDetails(.routeAction(.editTeachers(lesson))))):
                // TODO: Use another approach
                let editLessonTeachersState = EditLessonTeachers.State(lesson: lesson)
                state.path.append(.editLessonTeachers(editLessonTeachersState))
                return .none
                
            case .path(.element(_, .lessonDetails(.routeAction(.dismiss)))):
                state.path.removeLast()
                return .none

            case .path(.element(_, .editLessonNames(.routeAction(.dismiss)))):
                state.path.removeLast()
                return .none

            case .path(.element(_, .editLessonTeachers(.routeAction(.dismiss)))):
                state.path.removeLast()
                return .none

            case .path:
                return .none
                
            case .rozkladRoot:
                return .none
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.rozkladRoot, action: /Action.rozkladRoot) {
            RozkladRoot()
        }
        core
            .forEach(\.path, action: /Action.path) {
                Path()
            }
    }
    
    private func setRootRozkladState(from rozkladState: RozkladClientState.State, state: inout State) {
        switch rozkladState {
        case .selected:
            state.rozkladRoot = .groupRozklad(GroupRozklad.State())

        case .notSelected:
            state.rozkladRoot = .groupPicker(GroupPickerFeature.State(mode: .rozkladTab))
        }
    }
}
