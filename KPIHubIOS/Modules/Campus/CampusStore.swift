//
//  CampusStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import Combine

struct Campus: Reducer {
    struct State: Equatable {
        var campusRoot: CampusRoot.State?
        var path = StackState<Path.State>()
    }
    
    enum Action: Equatable {
        case onSetup
        case updateCampusState(CampusClientState.State)
        
        case campusRoot(CampusRoot.Action)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    @Dependency(\.campusClientState) var campusClientState
    @Dependency(\.campusClientStudySheet) var campusClientStudySheet
    
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onSetup:
                updateCampusState(with: campusClientState.subject.value, state: &state)
                return .merge(
                    Effect.run { subscriber in
                        campusClientState.subject
                            .dropFirst()
                            .removeDuplicates()
                            .receive(on: DispatchQueue.main)
                            .sink { state in
                                subscriber.send(.updateCampusState(state))
                            }
                    },
                    campusClientStudySheet.load()
                        .fireAndForget()
                )
                .cancellable(id: CancelID.campusClient, cancelInFlight: true)
                
            case let .updateCampusState(campusState):
                updateCampusState(with: campusState, state: &state)
                return .none
                
            case .campusRoot(.campusLogin(.route(.done))):
                campusClientState.commit()
                return campusClientStudySheet.load()
                    .fireAndForget()

            case let .campusRoot(.campusHome(.routeAction(.studySheet(items)))):
                let studySheetState = StudySheet.State(items: items)
                state.path.append(.studySheet(studySheetState))
                return .none
                
            case let .path(.element(_, .studySheet(.routeAction(.openDetail(item))))):
                let studySheetItemDetailState = StudySheetItemDetail.State(item: item)
                state.path.append(.studySheetItemDetail(studySheetItemDetailState))
                return .none
                
            case .campusRoot:
                return .none

            case .path:
                return .none
            }
        }
    }

    var body: some ReducerOf<Self> {
        core
            .ifLet(\.campusRoot, action: /Action.campusRoot) {
                CampusRoot()
            }
            .forEach(\.path, action: /Action.path) {
                Path()
            }
    }
    
    private func updateCampusState(with campusState: CampusClientState.State, state: inout State) {
        switch campusState {
        case .loggedOut:
            state.campusRoot = .campusLogin(CampusLoginFeature.State(mode: .onlyCampus))
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

struct CampusRoot: Reducer {
    enum State: Equatable {
        case campusLogin(CampusLoginFeature.State)
        case campusHome(CampusHome.State)
    }
    
    enum Action: Equatable {
        case campusLogin(CampusLoginFeature.Action)
        case campusHome(CampusHome.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: /State.campusLogin, action: /Action.campusLogin) {
            CampusLoginFeature()
        }
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
            case .campusLogin:
                CaseLet(
                    /CampusRoot.State.campusLogin,
                    action: CampusRoot.Action.campusLogin,
                    then: CampusLoginView.init(store:)
                )
                
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
