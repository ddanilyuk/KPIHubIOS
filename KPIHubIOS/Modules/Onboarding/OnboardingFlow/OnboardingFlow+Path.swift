//
//  OnboardingFlow+Path.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture

extension OnboardingFlow {
    struct Path {}
}

extension OnboardingFlow.Path: Reducer {
    enum State: Equatable {
        case campusLogin(CampusLoginFeature.State)
        case groupPicker(GroupPickerFeature.State)
    }
    
    enum Action: Equatable {
        case campusLogin(CampusLoginFeature.Action)
        case groupPicker(GroupPickerFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.campusLogin, action: /Action.campusLogin) {
            CampusLoginFeature()
        }
        Scope(state: /State.groupPicker, action: /Action.groupPicker) {
            GroupPickerFeature()
        }
    }
}
