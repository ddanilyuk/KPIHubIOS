//
//  AppFeature.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import Foundation
import Firebase
import UniversityHubKit
import GroupPickerFeature

@Reducer
struct AppDelegateFeature: Reducer {
    struct State: Equatable { }
    
    enum Action: Equatable {
        case didFinishLaunching(Bundle)
    }
    
    @Dependency(\.firebaseService) var firebaseService
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case let .didFinishLaunching(bundle):
                firebaseService.setup(bundle)
                return .none
            }
        }
    }
}


@Reducer
struct AppFeature: Reducer {
    @ObservableState
    struct State: Equatable {
        var appDelegate = AppDelegateFeature.State()
        var destination: Destination.State?
    }
    
    enum Action {
        case appDelegate(AppDelegateFeature.Action)
        case destination(Destination.Action)
    }
    
    @Dependency(\.userDefaultsService) var userDefaultsService
        
    var core: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appDelegate(.didFinishLaunching):
//                if userDefaultsService.get(for: .onboardingPassed) {
                state.destination = .main(MainFlow.State())
//                } else {
//                    state.destination = .onboarding(OnboardingFlow.State())
//                }
                return .none
                                
//            case .destination(.onboarding(.output(.done))):
//                state.destination = .main(MainFlow.State())
//                return .none
                
            case .appDelegate:
                return .none
                
            case .destination:
                return .none
            }
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.appDelegate, action: \.appDelegate) {
            AppDelegateFeature()
        }
        core
            .ifLet(\.destination, action: \.destination) {
                Destination()
            }
    }
}
