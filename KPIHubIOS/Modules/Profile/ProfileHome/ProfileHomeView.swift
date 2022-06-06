//
//  ProfileHomeView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct ProfileHomeView: View {

    let store: Store<ProfileHome.State, ProfileHome.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(spacing: 32) {

                    RozkladSectionView(
                        rozkladState: viewStore.rozkladState,
                        onChangeGroup: { viewStore.send(.changeGroup) },
                        onSelectGroup: { viewStore.send(.selectGroup) }
                    )

                    CampusSectionView(
                        campusState: viewStore.campusState,
                        onLogoutCampus: { viewStore.send(.campusLogout) },
                        onLoginCampus: { viewStore.send(.campusLogin) }
                    )
                }
                .padding(16)
            }
            .navigationTitle("Профіль")
            .onAppear {
                viewStore.send(.onAppear)
            }
            .background(Color.screenBackground)
        }
    }

}

// MARK: - Preview

struct ProfileHomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileHomeView(
                store: Store(
                    initialState: ProfileHome.State(
                        rozkladState: .notSelected,
                        campusState: .loggedOut
                    ),
                    reducer: ProfileHome.reducer,
                    environment: ProfileHome.Environment(
                        userDefaultsClient: .live(),
                        rozkladClient: .live(userDefaultsClient: .live()),
                        campusClient: .live(apiClient: .failing, userDefaultsClient: .live())
                    )
                )
            )
        }
    }
}
