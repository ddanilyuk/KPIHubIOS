//
//  ForDevelopers.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import ComposableArchitecture

struct ForDevelopers {

    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable { }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, _, _ in
        return .none
    }

}
