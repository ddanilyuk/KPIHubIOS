//
//  RozkladStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators
import IdentifiedCollections
import Foundation

struct RozkladRoot: Reducer {
    enum State: Equatable {
        case groupRozklad(GroupRozklad.State)
        case groupPicker(GroupPicker.State)
    }
    
    enum Action: Equatable {
        case groupRozklad(GroupRozklad.Action)
        case groupPicker(GroupPicker.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: /State.groupRozklad, action: /Action.groupRozklad) {
            GroupRozklad()
        }
        Scope(state: /State.groupPicker, action: /Action.groupPicker) {
            GroupPicker()
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
        var path = StackState<ScreenProvider.State>()// <Route<ScreenProvider.State>>

        init() {
            self.rozkladRoot = .groupPicker(GroupPicker.State(mode: .rozkladTab))
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onSetup
        
        case updateRozkladState(RozkladClientState.State)
        case setGroupRozklad
        case setGroupPicker
        case rozkladRoot(RozkladRoot.Action)
        case path(StackAction<ScreenProvider.State, ScreenProvider.Action>)

//        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
//        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)
    }

    // MARK: - Environment
    
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.analyticsClient) var analyticsClient

    // MARK: - Reducer
    
    @ReducerBuilder<State, Action>
    var core: some ReducerProtocol<State, Action> {
        Scope(state: \.rozkladRoot, action: /Action.rozkladRoot) {
            RozkladRoot()
        }
        Reduce { state, action in
            switch action {
            case .onSetup:
                return Effect.merge(
                    Effect(value: .updateRozkladState(rozkladClientState.subject.value)),
                    Effect.run { subscriber in
                        rozkladClientState.subject
                            .dropFirst()
                            .removeDuplicates()
                            .receive(on: DispatchQueue.main)
                            .sink { state in
                                subscriber.send(.updateRozkladState(state))
                            }
                    }
                )
                
            case let .updateRozkladState(state):
                switch state {
                case .selected:
                    return Effect(value: .setGroupRozklad)
                case .notSelected:
                    return Effect(value: .setGroupPicker)
                }

            case .setGroupRozklad:
                state.rozkladRoot = .groupRozklad(GroupRozklad.State())
//                state.routes = [
//                    .root(
//                        .groupRozklad(GroupRozklad.State()),
//                        embedInNavigationView: true
//                    )
//                ]
                return .none

            case .setGroupPicker:
                state.rozkladRoot = .groupPicker(GroupPicker.State(mode: .rozkladTab))
//                state.routes = [
//                    .root(
//                        .groupPicker(GroupPicker.State(mode: .rozkladTab)),
//                        embedInNavigationView: true
//                    )
//                ]
                return .none
                
            case let .rozkladRoot(.groupRozklad(.routeAction(.openDetails(lesson)))):
//            case let .path(.element(_, .groupRozklad(.routeAction(.openDetails(lesson))))):
                let lessonDetailsState = LessonDetails.State(
                    lesson: lesson
                )
                state.path.append(.lessonDetails(lessonDetailsState))
                return .none
                

//            case let .routeAction(_, .groupRozklad(.routeAction(.openDetails(lesson)))):
//                let lessonDetailsState = LessonDetails.State(
//                    lesson: lesson
//                )
//                state.routes.push(.lessonDetails(lessonDetailsState))
//                return .none

            case .rozkladRoot(.groupPicker(.routeAction(.done))):
                rozkladClientState.commit()
                rozkladClientLessons.commit()
                return .none

            case let .path(.element(_, .lessonDetails(.routeAction(.editNames(lesson))))):
                // TODO: Use another approach
                let editLessonNamesState = EditLessonNames.State(lesson: lesson)
                state.path.append(.editLessonNames(editLessonNamesState))
//                let editLessonNamesState = EditLessonNames.State(lesson: lesson)
//                state.routes.presentSheet(
//                    .editLessonNames(editLessonNamesState),
//                    embedInNavigationView: true
//                )
                return .none

            case let .path(.element(_, .lessonDetails(.routeAction(.editTeachers(lesson))))):
                // TODO: Use another approach
                let editLessonTeachersState = EditLessonTeachers.State(lesson: lesson)
                state.path.append(.editLessonTeachers(editLessonTeachersState))
//                state.routes.presentSheet(
//                    .editLessonTeachers(editLessonTeachersState),
//                    embedInNavigationView: true
//                )
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
    
    var body: some ReducerProtocol<State, Action> {
        core
            .forEach(\.path, action: /Action.path) {
                ScreenProvider()
            }
    }

}
