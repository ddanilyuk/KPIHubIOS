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
                        lessonsUpdatedDate: viewStore.updatedDate,
                        rozkladState: viewStore.rozkladState,
                        onUpdateRozklad: { viewStore.send(.updateRozkladButtonTapped) },
                        onChangeGroup: { viewStore.send(.changeGroupButtonTapped) },
                        onSelectGroup: { viewStore.send(.selectGroup) }
                    )

                    CampusSectionView(
                        campusState: viewStore.campusState,
                        onLogoutCampus: { viewStore.send(.campusLogoutButtonTapped) },
                        onLoginCampus: { viewStore.send(.campusLogin) }
                    )

                    OtherSectionView(
                        forDevelopers: { viewStore.send(.routeAction(.forDevelopers)) }
                    )
                }
                .padding(16)
            }
            .navigationTitle("Профіль")
            .onAppear {
                viewStore.send(.onAppear)
            }
            .background(Color.screenBackground)
            .loadable(viewStore.binding(\.$isLoading))
            .alert(
                self.store.scope(state: \.alert),
                dismiss: .dismissAlert
            )
            .confirmationDialog(
                self.store.scope(state: \.confirmationDialog),
                dismiss: .cancelTapped
            )
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
                        apiClient: .failing,
                        userDefaultsClient: .live(),
                        rozkladClient: .live(userDefaultsClient: .live()),
                        campusClient: .live(apiClient: .failing, userDefaultsClient: .live(), keychainClient: KeychainClient.live())
                    )
                )
            )
        }
    }
}
