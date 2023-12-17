//
//  OnboardingFlow+Path.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import RozkladKit
import GroupPickerFeature

extension OnboardingFlow {
    @Reducer
    public struct Path: Reducer {
        @ObservableState
        public enum State: Equatable {
//            case campusLogin(CampusLoginFeature.State)
            case groupPicker(GroupPickerFeature.State)
        }
        
        public enum Action {
//            case campusLogin(CampusLoginFeature.Action)
            case groupPicker(GroupPickerFeature.Action)
        }
        
        public var body: some ReducerOf<Self> {
//            Scope(state: \.campusLogin, action: \.campusLogin) {
//                CampusLoginFeature()
//            }
            Scope(state: \.groupPicker, action: \.groupPicker) {
                GroupPickerFeature()
            }
        }
    }
}
