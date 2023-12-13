//
//  ProfileFlowCoordinatorView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct ProfileFlowCoordinatorView: View {
    private let store: StoreOf<Profile>
    
    init(store: StoreOf<Profile>) {
        self.store = store
    }

    var body: some View {
        Color.blue
//        NavigationStackStore(
//            store.scope(state: \.path, action: Profile.Action.path),
//            root: {
//                ProfileHomeView(
//                    store: store.scope(
//                        state: \.profileHome,
//                        action: Profile.Action.profileHome
//                    )
//                )
//            },
//            destination: { destination in
//                switch destination {
//                case .forDevelopers:
//                    CaseLet(
//                        /Profile.ScreenProvider.State.forDevelopers,
//                        action: Profile.ScreenProvider.Action.forDevelopers,
//                        then: ForDevelopersView.init(store:)
//                    )
//                }
//            }
//        )
    }
}
