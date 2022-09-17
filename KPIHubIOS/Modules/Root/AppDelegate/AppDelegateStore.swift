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
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .didFinishLaunching:
                return .none
            }
        }
    }

}
