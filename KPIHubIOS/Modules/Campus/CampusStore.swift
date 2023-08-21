//
//  CampusStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators
import Combine
import Foundation

struct Campus: Reducer {

    // MARK: - State

    struct State: Equatable, IdentifiedRouterState {
        var routes: IdentifiedArrayOf<Route<ScreenProvider.State>>

        init() {
            self.routes = []
        }
    }

    // MARK: - Action

    enum Action: Equatable, IdentifiedRouterAction {
        case onSetup

        case updateCampusState(CampusClientState.State)
        case setCampusLogin
        case setCampusHome

        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)
    }

    // MARK: - Environment
    
    @Dependency(\.campusClientState) var campusClientState
    @Dependency(\.campusClientStudySheet) var campusClientStudySheet

    // MARK: - Reducer
    
    enum SubscriberCancelID { }
    
    @ReducerBuilder<State, Action>
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onSetup:
                return .merge(
                    Effect(value: .updateCampusState(campusClientState.subject.value)),
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
                .cancellable(id: SubscriberCancelID.self, cancelInFlight: true)

            case let .updateCampusState(state):
                switch state {
                case .loggedOut:
                    return Effect(value: .setCampusLogin)
                case .loggedIn:
                    return Effect(value: .setCampusHome)
                }

            case .setCampusLogin:
                state.routes = [
                    .root(
                        .campusLogin(CampusLoginFeature.State(mode: .onlyCampus)),
                        embedInNavigationView: true
                    )
                ]
                return .none

            case .setCampusHome:
                state.routes = [
                    .root(
                        .campusHome(CampusHome.State()),
                        embedInNavigationView: true
                    )
                ]
                return .none

            case .routeAction(_, .campusLogin(.route(.done))):
                campusClientState.commit()
                return campusClientStudySheet.load()
                    .fireAndForget()

            case let .routeAction(_, action: .campusHome(.routeAction(.studySheet(items)))):
                let studySheetState = StudySheet.State(items: items)
                state.routes.push(.studySheet(studySheetState))
                return .none

            case let .routeAction(_, .studySheet(.routeAction(.openDetail(item)))):
                let studySheetItemDetailState = StudySheetItemDetail.State(item: item)
                state.routes.push(.studySheetItemDetail(studySheetItemDetailState))
                return .none

            case .routeAction:
                return .none

            case .updateRoutes:
                return .none
            }
        }
    }

    var body: some ReducerOf<Self> {
        core.forEachRoute {
            Campus.ScreenProvider()
        }
    }
    
}
