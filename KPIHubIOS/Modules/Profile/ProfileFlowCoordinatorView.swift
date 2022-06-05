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
            Text("Profile \(viewStore.name)")
                .onAppear {
                    viewStore.send(.onAppear)
                }
        }
    }

}
