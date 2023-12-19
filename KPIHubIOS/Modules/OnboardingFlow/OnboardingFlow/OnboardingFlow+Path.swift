//
//  OnboardingFlow+Path.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import RozkladKit
import GroupPickerFeature
import CampusLoginFeature

extension OnboardingFlow {
    @Reducer
    struct Path: Reducer {
        @ObservableState
        enum State: Equatable {
            case campusLogin(CampusLoginFeature.State)
            case groupPicker(GroupPickerFeature.State)
        }
        
        enum Action {
            case campusLogin(CampusLoginFeature.Action)
            case groupPicker(GroupPickerFeature.Action)
        }
        
        var body: some ReducerOf<Self> {
            Scope(state: \.campusLogin, action: \.campusLogin) {
                CampusLoginFeature()
            }
            Scope(state: \.groupPicker, action: \.groupPicker) {
                GroupPickerFeature()
            }
        }
    }
}
