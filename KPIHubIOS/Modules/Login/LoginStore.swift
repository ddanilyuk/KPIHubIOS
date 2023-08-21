//
//  LoginStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators

struct Login: Reducer {

    // MARK: - State

    struct State: Equatable, IdentifiedRouterState {
        var routes: IdentifiedArrayOf<Route<ScreenProvider.State>>

        init() {
            self.routes = [
                .root(.onboarding(Onboarding.State()), embedInNavigationView: true)
            ]
        }
    }

    // MARK: - Action

    enum Action: Equatable, IdentifiedRouterAction {
        case routeAction(ScreenProvider.State.ID, action: ScreenProvider.Action)
        case updateRoutes(IdentifiedArrayOf<Route<ScreenProvider.State>>)
        case delegate(Delegate)

        enum Delegate: Equatable {
            case done
        }
    }

    // MARK: - Environment

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.campusClientState) var campusClientState
    @Dependency(\.analyticsClient) var analyticsClient

    // MARK: - Reducer

    @ReducerBuilder<State, Action>
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .routeAction(_, .onboarding(.routeAction(.groupPicker))):
                let groupPickerState = GroupPickerFeature.State(mode: .onboarding)
                state.routes.push(.groupPicker(groupPickerState))
                return .none

            case .routeAction(_, .onboarding(.routeAction(.campusLogin))):
                let campusLoginState = CampusLoginFeature.State(mode: .campusAndGroup)
                state.routes.push(.campusLogin(campusLoginState))
                return .none

            case .routeAction(_, .campusLogin(.route(.groupPicker))):
                let groupPickerState = GroupPickerFeature.State(mode: .campus)
                state.routes.push(.groupPicker(groupPickerState))
                return .none

            case .routeAction(_, .campusLogin(.route(.done))):
                campusClientState.commit()
                rozkladClientState.commit()
                rozkladClientLessons.commit()
                userDefaultsClient.set(true, for: .onboardingPassed)
                analyticsClient.track(Event.Onboarding.onboardingPassed)
                return .send(.delegate(.done))

            case .routeAction(_, .groupPicker(.route(.done))):
                campusClientState.commit()
                rozkladClientState.commit()
                rozkladClientLessons.commit()
                userDefaultsClient.set(true, for: .onboardingPassed)
                analyticsClient.track(Event.Onboarding.onboardingPassed)
                return .send(.delegate(.done))

            case .routeAction:
                return .none

            case .updateRoutes:
                return .none

            case .delegate:
                return .none
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        core.forEachRoute {
            Login.ScreenProvider()
        }
    }
}
