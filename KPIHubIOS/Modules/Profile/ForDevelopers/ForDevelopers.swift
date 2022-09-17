//
//  ForDevelopers.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import ComposableArchitecture

struct ForDevelopers: ReducerProtocol {

    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer
    
    func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
        switch action {
        case .onAppear:
            return .none
        }
    }

}
