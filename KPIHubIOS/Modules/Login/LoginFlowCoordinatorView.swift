//
//  LoginFlowCoordinatorView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct LoginFlowCoordinatorView: View {

    let store: Store<Login.State, Login.Action>

    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) {
                CaseLet(
                    state: /Login.ScreenProvider.State.onboarding,
                    action: Login.ScreenProvider.Action.onboarding,
                    then: OnboardingView.init
                )
                CaseLet(
                    state: /Login.ScreenProvider.State.campusLogin,
                    action: Login.ScreenProvider.Action.campusLogin,
                    then: CampusLoginView.init
                )
                CaseLet(
                    state: /Login.ScreenProvider.State.groupPicker,
                    action: Login.ScreenProvider.Action.groupPicker,
                    then: GroupPickerView.init
                )
            }
        }
    }
    
}
