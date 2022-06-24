//
//  CampusSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 07.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct CampusSectionView: View {

    struct ViewState: Equatable {
        let campusState: CampusClient.StateModule.State
        let fullName: String
        let cathedra: String
    }

    enum ViewAction {
        case loginCampus
        case logoutCampus
    }

    let store: Store<ViewState, ViewAction>
    @ObservedObject var viewStore: ViewStore<ViewState, ViewAction>

    init(store: Store<ViewState, ViewAction>) {
        self.store = store
        self.viewStore = ViewStore(store)
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

    var loggedInView: some View {
        VStack(alignment: .leading, spacing: 20) {

            ProfileCellView(
                title: "Ім'я:",
                value: .text(viewStore.fullName),
                image: {
                    Image(systemName: "person")
                        .foregroundColor(Color(red: 247 / 255, green: 244 / 255, blue: 255 / 255))
                },
                imageBackgroundColor: Color(red: 91 / 255, green: 46 / 255, blue: 255 / 255)
            )

            ProfileCellView(
                title: "Кафедра:",
                value: .text(viewStore.cathedra),
                image: {
                    Image(systemName: "graduationcap")
                        .foregroundColor(Color(red: 237 / 255, green: 246 / 255, blue: 254 / 255))
                },
                imageBackgroundColor: Color(red: 37 / 255, green: 114 / 255, blue: 228 / 255)
            )

            Divider()

            Button(
                action: { viewStore.send(.logoutCampus) },
                label: {
                    Text("Вийти з аккаунту")
                        .font(.system(.body).bold())
                        .foregroundColor(.red)

                    Spacer()
                }
            )

        }
    }

    var loggedOutView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Divider()

            Button(
                action: { viewStore.send(.loginCampus) },
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

// MARK: - ViewState

extension CampusSectionView.ViewState {

    init(profileHomeState: ProfileHome.State) {
        self.campusState = profileHomeState.campusState
        let campusUserInfoPath = /CampusClient.StateModule.State.loggedIn
        let campusUserInfo = campusUserInfoPath.extract(from: campusState)
        self.fullName = campusUserInfo?.fullName ?? "-"
        self.cathedra = campusUserInfo?.subdivision.first?.name ?? "-"
    }

}

// MARK: - ViewAction

extension ProfileHome.Action {

    init(campusSection: CampusSectionView.ViewAction) {
        switch campusSection {
        case .logoutCampus:
            self = .campusLogoutButtonTapped

        case .loginCampus:
            self = .campusLogin
        }
    }

}

// MARK: - Preview

struct CampusSectionView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            CampusSectionView(
                store: Store(
                    initialState: CampusSectionView.ViewState(
                        campusState: .loggedOut,
                        fullName: "",
                        cathedra: ""
                    ),
                    reducer: Reducer.empty,
                    environment: Void()
                )
            )
            .smallPreview
            .padding(16)
            .background(Color.screenBackground)

            CampusSectionView(
                store: Store(
                    initialState: CampusSectionView.ViewState(
                        campusState: .loggedIn(
                            CampusUserInfo.mock
                        ),
                        fullName: CampusUserInfo.mock.fullName,
                        cathedra: CampusUserInfo.mock.subdivision.first?.name ?? "-"
                    ),
                    reducer: Reducer.empty,
                    environment: Void()
                )
            )
            .smallPreview
            .padding(16)
            .background(Color.screenBackground)

        }
    }
}
