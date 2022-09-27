//
//  AppDelegateStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

struct AppDelegateReducer: ReducerProtocol {
    
    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable {
        case didFinishLaunching
    }

    // MARK: - Reducer
    
    @Dependency(\.firebaseClient) var firebaseClient
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .didFinishLaunching:
                firebaseClient.setup()
                return .none
            }
        }
    }

}
