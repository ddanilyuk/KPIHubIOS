//
//  ProfileFlowCoordinatorView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct ProfileFlowCoordinatorView: View {

    let store: Store<Profile.State, Profile.Action>

    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) {
                CaseLet(
                    state: /Profile.ScreenProvider.State.profileHome,
                    action: Profile.ScreenProvider.Action.profileHome,
                    then: ProfileHomeView.init
                )
                CaseLet(
                    state: /Profile.ScreenProvider.State.forDevelopers,
                    action: Profile.ScreenProvider.Action.forDevelopers,
                    then: ForDevelopersView.init
                )
            }
        }
    }

}
