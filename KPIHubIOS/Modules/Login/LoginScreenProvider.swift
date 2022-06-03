//
//  LoginScreenProvider.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

extension Login {

    struct ScreenProvider {}

}

extension Login.ScreenProvider {

    // MARK: - State handling

    enum State: Equatable, CoordinatorStateIdentifiable {

        static var module: Any.Type = Login.self

        case onboarding(Onboarding.State)
        case campusLogin(CampusLogin.State)
        case groupPicker(GroupPicker.State)
    }

    // MARK: - Action handling

    enum Action: Equatable {
        case onboarding(Onboarding.Action)
        case campusLogin(CampusLogin.Action)
        case groupPicker(GroupPicker.Action)
    }

    // MARK: - Reducer handling

    static let reducer = Reducer<State, Action, Login.Environment>.combine(
        Onboarding.reducer
            .pullback(
                state: /State.onboarding,
                action: /Action.onboarding,
                environment: { _ in Onboarding.Environment() }
            ),
        CampusLogin.reducer
            .pullback(
                state: /State.campusLogin,
                action: /Action.campusLogin,
                environment: {
                    CampusLogin.Environment(
                        apiClient: $0.apiClient,
                        userDefaultsClient: $0.userDefaultsClient
                    )
                }
            ),
        GroupPicker.reducer
            .pullback(
                state: /State.groupPicker,
                action: /Action.groupPicker,
                environment: {
                    GroupPicker.Environment(
                        apiClient: $0.apiClient
                    )
                }
            )
    )

}
