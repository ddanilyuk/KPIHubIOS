//
//  OnboardingFlow.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

struct OnboardingFlow: Reducer {
    struct State: Equatable {
        var path = StackState<Path.State>()
        var onboarding = OnboardingFeature.State()
    }
    
    enum Action: Equatable {
        case onboarding(OnboardingFeature.Action)
        case path(StackAction<Path.State, Path.Action>)
        case output(Output)
        
        enum Output: Equatable {
            case done
        }
    }
    
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.campusClientState) var campusClientState
    @Dependency(\.analyticsClient) var analyticsClient
    
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onboarding(.routeAction(.groupPicker)):
                let groupPickerState = GroupPickerFeature.State(mode: .onboarding)
                state.path.append(.groupPicker(groupPickerState))
                return .none
                
            case .onboarding(.routeAction(.campusLogin)):
                let campusLoginState = CampusLoginFeature.State(mode: .campusAndGroup)
                state.path.append(.campusLogin(campusLoginState))
                return .none
                
            case .path(.element(_, .campusLogin(.route(.groupPicker)))):
                let groupPickerState = GroupPickerFeature.State(mode: .campus)
                state.path.append(.groupPicker(groupPickerState))
                return .none
                
            case .path(.element(_, .campusLogin(.route(.done)))):
                campusClientState.commit()
                rozkladClientState.commit()
                rozkladClientLessons.commit()
                userDefaultsClient.set(true, for: .onboardingPassed)
                analyticsClient.track(Event.Onboarding.onboardingPassed)
                return .send(.output(.done))
                
            case .path(.element(_, .groupPicker(.route(.done)))):
                campusClientState.commit()
                rozkladClientState.commit()
                rozkladClientLessons.commit()
                userDefaultsClient.set(true, for: .onboardingPassed)
                analyticsClient.track(Event.Onboarding.onboardingPassed)
                return .send(.output(.done))
                
            case .onboarding:
                return .none
                
            case .path:
                return .none
                
            case .output:
                return .none
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \State.onboarding, action: /Action.onboarding) {
            OnboardingFeature()
        }
        core.forEach(\.path, action: /Action.path) {
            Path()
        }
    }
}
