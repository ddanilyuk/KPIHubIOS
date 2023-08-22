//
//  RozkladFlow.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import IdentifiedCollections
import Foundation

struct RozkladFlow: Reducer {
    struct State: Equatable {
        var rozkladRoot: RozkladRoot.State
        var path = StackState<Path.State>()

        init() {
            self.rozkladRoot = .groupPicker(GroupPickerFeature.State(mode: .rozkladTab))
        }
    }
    
    enum Action: Equatable {
        case onSetup
        
        case updateRozkladState(RozkladClientState.State)
        case rozkladRoot(RozkladRoot.Action)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    @Dependency(\.analyticsService) var analyticsService
    
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
                rozkladServiceLessons.commit()
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
        core.forEach(\.path, action: /Action.path) {
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
