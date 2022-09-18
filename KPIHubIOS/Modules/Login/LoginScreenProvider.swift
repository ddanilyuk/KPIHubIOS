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

extension Login.ScreenProvider: ReducerProtocol {

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
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: /State.onboarding, action: /Action.onboarding) {
            Onboarding()
        }
        Scope(state: /State.campusLogin, action: /Action.campusLogin) {
            CampusLogin()
        }
        Scope(state: /State.groupPicker, action: /Action.groupPicker) {
            GroupPicker()
        }
    }
    
}
