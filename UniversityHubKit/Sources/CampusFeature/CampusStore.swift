//
//  CampusStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import Combine
import GeneralServices
import CampusModels
import CampusServices

@Reducer
public struct Campus: Reducer {
    public struct State: Equatable {
        var campusRoot: CampusRoot.State?
        var path = StackState<Path.State>()
        
        public init() { }
    }
    
    public enum Action: Equatable {
        case onSetup
        case updateCampusState(CampusServiceState.State)
        
        case campusRoot(CampusRoot.Action)
        // case path(StackAction<Path.State, Path.Action>)
    }
    
    @Dependency(\.campusClientState) var campusClientState
    @Dependency(\.campusServiceStudySheet) var campusServiceStudySheet
    
    public init() { }
    
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onSetup:
                updateCampusState(with: campusClientState.currentState(), state: &state)
                return .merge(
                    .run { send in
                        for await state in campusClientState.stateStream().dropFirst() {
                            await send(.updateCampusState(state))
                        }
                    },
                    .run { _ in
                        await campusServiceStudySheet.load()
                    }
                )
                .cancellable(id: CancelID.campusClient, cancelInFlight: true)
                
            case let .updateCampusState(campusState):
                updateCampusState(with: campusState, state: &state)
                return .none
                
//            case .campusRoot(.campusLogin(.route(.done))):
//                campusClientState.commit()
//                return .run { _ in
//                    await campusServiceStudySheet.load()
//                }
                
            case let .campusRoot(.campusHome(.routeAction(.studySheet(items)))):
                let studySheetState = StudySheet.State(items: items)
                state.path.append(.studySheet(studySheetState))
                return .none
                
//            case let .path(.element(_, .studySheet(.routeAction(.openDetail(item))))):
//                let studySheetItemDetailState = StudySheetItemDetail.State(item: item)
//                state.path.append(.studySheetItemDetail(studySheetItemDetailState))
//                return .none
//                
            case .campusRoot:
                return .none

//            case .path:
//                return .none
            }
        }
    }

    public var body: some ReducerOf<Self> {
        core
            .ifLet(\.campusRoot, action: \.campusRoot) {
                CampusRoot()
            }
//            .forEach(\.path, action: \.path) {
//                Path()
//            }
    }
    
    private func updateCampusState(with campusState: CampusServiceState.State, state: inout State) {
        switch campusState {
        case .loggedOut:
            break
//            state.campusRoot = .campusLogin(CampusLoginFeature.State(mode: .onlyCampus))

        case .loggedIn:
            state.campusRoot = .campusHome(CampusHome.State())
        }
    }
}

extension Campus {
    enum CancelID {
        case campusClient
    }
}


public struct CampusRoot: Reducer {
    public enum State: Equatable {
//        case campusLogin(CampusLoginFeature.State)
        case campusHome(CampusHome.State)
    }
    
    public enum Action: Equatable {
//        case campusLogin(CampusLoginFeature.Action)
        case campusHome(CampusHome.Action)
    }

    public var body: some ReducerOf<Self> {
//        Scope(state: /State.campusLogin, action: /Action.campusLogin) {
//            CampusLoginFeature()
//        }
        Scope(state: /State.campusHome, action: /Action.campusHome) {
            CampusHome()
        }
    }
}

import SwiftUI
struct CampusRootView: View {
    let store: StoreOf<CampusRoot>
    
    var body: some View {
        SwitchStore(store) { state in
            switch state {
//            case .campusLogin:
//                CaseLet(
//                    /CampusRoot.State.campusLogin,
//                    action: CampusRoot.Action.campusLogin,
//                    then: CampusLoginView.init(store:)
//                )
                
            case .campusHome:
                CaseLet(
                    /CampusRoot.State.campusHome,
                    action: CampusRoot.Action.campusHome,
                    then: CampusHomeView.init(store:)
                )
            }
        }
    }
}
