//
//  AppDelegateFeature.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

struct AppDelegateFeature: Reducer {
    struct State: Equatable { }
    
    enum Action: Equatable {
        case didFinishLaunching
    }
    
    @Dependency(\.firebaseService) var firebaseService
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .didFinishLaunching:
                firebaseService.setup()
                return .none
            }
        }
    }
}
