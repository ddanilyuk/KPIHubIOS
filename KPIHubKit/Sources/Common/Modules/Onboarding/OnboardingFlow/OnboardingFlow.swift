//
//  OnboardingFlow.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

//@Reducer
//public struct OnboardingFlow2: Reducer {
//    @ObservableState
//    public struct State: Equatable { }
//    
//    public enum Action: Equatable {
//        
//    }
//    
//    public var body: some ReducerOf<Self> {
//        EmptyReducer()
//    }
//}
//
//import SwiftUI
//
//public struct OnboardingView2: View {
//    private let store: StoreOf<OnboardingFlow2>
//    
//    public init(store: StoreOf<OnboardingFlow2>) {
//        self.store = store
//    }
//    
//    public var body: some View {
//        Color.red
//    }
//}

@Reducer
public struct OnboardingFlow: Reducer {
    @ObservableState
    public struct State: Equatable {
//        var path = StackState<Path.State>()
        var onboarding = OnboardingFeature.State()
    }
    
    public enum Action: Equatable {
        case onboarding(OnboardingFeature.Action)
//        case path(StackAction<Path.State, Path.Action>)
//        case output(Output)
//        
//        public enum Output: Equatable {
//            case done
//        }
    }
    
    @Dependency(\.userDefaultsService) var userDefaultsService
    @Dependency(\.rozkladServiceState) var rozkladServiceState
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    @Dependency(\.campusClientState) var campusClientState
    @Dependency(\.analyticsService) var analyticsService
    
    @ReducerBuilder<State, Action>
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onboarding(.output(.groupPicker)):
                let groupPickerState = GroupPickerFeature.State(mode: .onboarding)
                // state.path.append(.groupPicker(groupPickerState))
                return .none
                
            case .onboarding(.output(.campusLogin)):
                let campusLoginState = CampusLoginFeature.State(mode: .campusAndGroup)
                // state.path.append(.campusLogin(campusLoginState))
                return .none
                
//            case .path(.element(_, .campusLogin(.route(.groupPicker)))):
//                let groupPickerState = GroupPickerFeature.State(mode: .campus)
//                state.path.append(.groupPicker(groupPickerState))
//                return .none
//                
//            case .path(.element(_, .campusLogin(.route(.done)))):
//                campusClientState.commit()
//                rozkladServiceState.commit()
//                rozkladServiceLessons.commit()
//                userDefaultsService.set(true, for: .onboardingPassed)
//                analyticsService.track(Event.Onboarding.onboardingPassed)
//                return .send(.output(.done))
//                
//            case .path(.element(_, .groupPicker(.route(.done)))):
//                campusClientState.commit()
//                rozkladServiceState.commit()
//                rozkladServiceLessons.commit()
//                userDefaultsService.set(true, for: .onboardingPassed)
//                analyticsService.track(Event.Onboarding.onboardingPassed)
//                return .send(.output(.done))
                
            case .onboarding:
                return .none
                
//            case .path:
//                return .none
                
//            case .output:
//                return .none
            }
        }
    }
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        core
//            .forEach(\.path, action: \.path) {
//                Path()
//            }
    }
}
