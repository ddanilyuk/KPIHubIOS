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
                        store: store.scope(
                            state: RozkladSectionView.ViewState.init(profileHomeState:),
                            action: ProfileHome.Action.init(rozkladSection:)
                        )
                    )

                    CampusSectionView(
                        store: store.scope(
                            state: CampusSectionView.ViewState.init(profileHomeState:),
                            action: ProfileHome.Action.init(campusSection:)
                        )
                    )

                    OtherSectionView(
                        store: store.scope(
                            state: { _ in OtherSectionView.ViewState() },
                            action: ProfileHome.Action.init(otherSection:)
                        )
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
                dismiss: .dismissConfirmationDialog
            )
        }
    }

}

// MARK: - Preview

struct ProfileHomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
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
                            userDefaultsClient: mockDependencies.userDefaults,
                            rozkladClient: .mock(),
                            campusClient: .live(apiClient: .failing, userDefaultsClient: mockDependencies.userDefaults, keychainClient: KeychainClient.live())
                        )
                    )
                )
            }

            NavigationView {
                ProfileHomeView(
                    store: Store(
                        initialState: ProfileHome.State(
                            rozkladState: .selected(GroupResponse(id: UUID(), name: "ІВ-82")),
                            campusState: .loggedIn(CampusUserInfo.mock)
                        ),
                        reducer: ProfileHome.reducer,
                        environment: ProfileHome.Environment(
                            apiClient: .failing,
                            userDefaultsClient: mockDependencies.userDefaults,
                            rozkladClient: .mock(),
                            campusClient: .live(apiClient: .failing, userDefaultsClient: mockDependencies.userDefaults, keychainClient: KeychainClient.live())
                        )
                    )
                )
            }
        }
    }
}
