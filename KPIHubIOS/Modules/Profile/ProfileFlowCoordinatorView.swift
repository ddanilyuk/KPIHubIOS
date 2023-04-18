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

    let store: StoreOf<Profile>

    var body: some View {
        NavigationStackStore(
            self.store.scope(state: \Profile.State.path, action: Profile.Action.path),
            root: {
                // TODO: Do we need Root?
                Text("Root")
            },
            destination: { destination in
                switch destination {
                case .profileHome:
                    CaseLet(
                        state: /Profile.ScreenProvider.State.profileHome,
                        action: Profile.ScreenProvider.Action.profileHome,
                        then: ProfileHomeView.init(store:)
                    )
                    
                case .forDevelopers:
                    CaseLet(
                        state: /Profile.ScreenProvider.State.forDevelopers,
                        action: Profile.ScreenProvider.Action.forDevelopers,
                        then: ForDevelopersView.init(store:)
                    )
                }
            }
        )
//        TCARouter(store) { screen in
//            SwitchStore(screen) {
//                CaseLet(
//                    state: /Profile.ScreenProvider.State.profileHome,
//                    action: Profile.ScreenProvider.Action.profileHome,
//                    then: ProfileHomeView.init
//                )
//                CaseLet(
//                    state: /Profile.ScreenProvider.State.forDevelopers,
//                    action: Profile.ScreenProvider.Action.forDevelopers,
//                    then: ForDevelopersView.init
//                )
//            }
//        }
    }

}
