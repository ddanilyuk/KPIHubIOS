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
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    WithViewStore(
                        self.store.scope(
                            state: \ProfileHome.State.rozkladSectionView,
                            action: ProfileHome.Action.rozkladSectionView
                        ),
                        content: RozkladSectionView.init(viewStore:)
                    )

                    WithViewStore(
                        self.store.scope(
                            state: \ProfileHome.State.campusSectionView,
                            action: ProfileHome.Action.campusSectionView
                        ),
                        content: CampusSectionView.init(viewStore:)
                    )

                    WithViewStore(
                        self.store.scope(
                            state: \ProfileHome.State.otherSectionView,
                            action: ProfileHome.Action.otherSectionView
                        ),
                        content: OtherSectionView.init(viewStore:)
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
                            userDefaultsClient: .mock(),
                            rozkladClient: .mock(),
                            campusClient: .mock(),
                            currentDateClient: .mock(),
                            appConfiguration: .mock()
                        )
                    )
                )
            }

            NavigationView {
                ProfileHomeView(
                    store: Store(
                        initialState: ProfileHome.State(
                            rozkladState: .selected(GroupResponse(id: UUID(), name: "ІВ-82", faculty: "ФІОТ")),
                            campusState: .loggedIn(CampusUserInfo.mock)
                        ),
                        reducer: ProfileHome.reducer,
                        environment: ProfileHome.Environment(
                            apiClient: .failing,
                            userDefaultsClient: .mock(),
                            rozkladClient: .mock(),
                            campusClient: .mock(),
                            currentDateClient: .mock(),
                            appConfiguration: .mock()
                        )
                    )
                )
            }
        }
    }
}
