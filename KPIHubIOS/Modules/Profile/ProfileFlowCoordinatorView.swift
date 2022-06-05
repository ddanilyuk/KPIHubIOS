//
//  ProfileFlowCoordinatorView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct ProfileFlowCoordinatorView: View {

    let store: Store<Profile.State, Profile.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                Text("Profile \(viewStore.name)")
                    .onAppear {
                        viewStore.send(.onAppear)
                    }
                Button(
                    action: {
                        viewStore.send(.logOutCampus)
                    },
                    label: {
                        Text("Log out camapus")
                    }
                )
                Button(
                    action: {
                        viewStore.send(.logOutGroup)
                    },
                    label: {
                        Text("Log out group")
                    }
                )
            }

        }
    }

}
