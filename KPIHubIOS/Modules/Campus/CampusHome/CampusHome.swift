//
//  CampusHome.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture

struct CampusHome {

    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable {

        case routeAction(RouteAction)

        enum RouteAction {
            case studySheet
        }
    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .routeAction:
            return .none
        }
    }

}
