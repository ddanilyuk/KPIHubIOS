//
//  CampusSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 07.06.2022.
//

import SwiftUI
import ComposableArchitecture
import Common

/// Not ideal approach of ViewAction
struct CampusSectionView: View {
    struct ViewState: Equatable {
        let campusState: CampusServiceState.State
        let fullName: String
        let cathedra: String
        
        init(state: ProfileHome.State) {
            let campusUserInfoPath = /CampusServiceState.State.loggedIn
            let campusUserInfo = campusUserInfoPath.extract(from: state.campusState)
            
            campusState = state.campusState
            fullName = campusUserInfo?.fullName ?? "-"
            cathedra = campusUserInfo?.subdivision.first?.name ?? "-"
        }
    }
    
    @ObservedObject private var viewStore: ViewStore<ViewState, ProfileHome.Action.View>
    
    init(store: StoreOf<ProfileHome>) {
        self.viewStore = ViewStore(store, observe: ViewState.init, send: { .view($0) })
    }

    var body: some View {
        ProfileSectionView(
            title: "Кампус",
            content: {
                switch viewStore.campusState {
                case .loggedIn:
                    loggedInView
                case .loggedOut:
                    loggedOutView
                }
            }
        )
    }

    private var loggedInView: some View {
        VStack(alignment: .leading, spacing: 16) {

            ProfileCellView(
                title: "Ім'я:",
                value: .text(viewStore.fullName),
                image: {
                    Image(systemName: "person")
                        .foregroundColor(Color.mint.lighter(by: 0.9))
                },
                imageBackgroundColor: Color.mint
            )

            ProfileCellView(
                title: "Кафедра:",
                value: .text(viewStore.cathedra),
                image: {
                    Image(systemName: "graduationcap")
                        .foregroundColor(Color.cyan.lighter(by: 0.9))
                },
                imageBackgroundColor: Color.cyan
            )

            Divider()

            Button(
                action: { viewStore.send(.logoutCampusButtonTapped) },
                label: {
                    Text("Вийти з аккаунту")
                        .font(.system(.body).bold())
                        .foregroundColor(.red)

                    Spacer()
                }
            )

        }
    }

    private var loggedOutView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()

            Button(
                action: { viewStore.send(.loginCampusButtonTapped) },
                label: {
                    Text("Увійти у кампус")
                        .font(.system(.body).bold())
                        .foregroundColor(.green)

                    Spacer()
                }
            )
        }
    }
}

// MARK: - Preview
#Preview {
    CampusSectionView(
        store: Store(
            initialState: ProfileHome.State(campusState: .loggedIn(CampusUserInfo.mock))
        ) {
            ProfileHome()
        }
    )
    .smallPreview
    .padding(16)
    .background(Color.screenBackground)
}

#Preview {
    CampusSectionView(
        store: Store(
            initialState: ProfileHome.State(campusState: .loggedOut)
        ) {
            ProfileHome()
        }
    )
    .smallPreview
    .padding(16)
    .background(Color.screenBackground)
}
