//
//  EditLessonNamesStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture

struct EditLessonNames {

    // MARK: - State

    struct State: Equatable {
        let names: [String]
        var selected: [String]

        init(names: [String], selected: [String]) {
            self.names = names
            self.selected = selected
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case save
        case cancel

        case toggle(String)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case save([String])
            case cancel
        }
    }

    // MARK: - Environment

    struct Environment {
        let userDefaultsClient: UserDefaultsClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .save:
            return Effect(value: .routeAction(.save(state.selected)))

        case .cancel:
            return Effect(value: .routeAction(.cancel))

        case let .toggle(element):
            if let index = state.selected.firstIndex(of: element) {
                if state.selected.count > 1 {
                    state.selected.remove(at: index)
                }
            } else {
                state.selected.append(element)
            }
            return .none

        case .routeAction:
            return .none
        }
    }

}
