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

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .didFinishLaunching:
            return .none
        }
    }

}
