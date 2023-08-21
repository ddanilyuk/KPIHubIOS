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

extension Login.ScreenProvider: Reducer {

    // MARK: - State handling

    enum State: Equatable, CoordinatorStateIdentifiable {

        static var module: Any.Type = Login.self

        case onboarding(Onboarding.State)
        case campusLogin(CampusLoginFeature.State)
        case groupPicker(GroupPickerFeature.State)
    }

    // MARK: - Action handling

    enum Action: Equatable {
        case onboarding(Onboarding.Action)
        case campusLogin(CampusLoginFeature.Action)
        case groupPicker(GroupPickerFeature.Action)
    }

    // MARK: - Reducer handling
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.onboarding, action: /Action.onboarding) {
            Onboarding()
        }
        Scope(state: /State.campusLogin, action: /Action.campusLogin) {
            CampusLoginFeature()
        }
        Scope(state: /State.groupPicker, action: /Action.groupPicker) {
            GroupPickerFeature()
        }
    }
    
}
