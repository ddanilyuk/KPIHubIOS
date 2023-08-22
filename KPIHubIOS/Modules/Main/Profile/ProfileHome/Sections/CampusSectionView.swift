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
        let campusState: CampusServiceState.State
        let fullName: String
        let cathedra: String
    }

    enum ViewAction {
        case loginCampus
        case logoutCampus
    }

    @ObservedObject var viewStore: ViewStore<ViewState, ViewAction>

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
        VStack(alignment: .leading, spacing: 16) {
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

extension ProfileHome.State {

    var campusSectionView: CampusSectionView.ViewState {
        let campusUserInfoPath = /CampusServiceState.State.loggedIn
        let campusUserInfo = campusUserInfoPath.extract(from: self.campusState)
        return CampusSectionView.ViewState(
            campusState: self.campusState,
            fullName: campusUserInfo?.fullName ?? "-",
            cathedra: campusUserInfo?.subdivision.first?.name ?? "-"
        )
    }

}

// MARK: - ViewAction

extension ProfileHome.Action {

    static func campusSectionView(_ viewAction: CampusSectionView.ViewAction) -> Self {
        switch viewAction {
        case .logoutCampus:
            return .logoutCampusButtonTapped

        case .loginCampus:
            return .loginCampus
        }
    }

}

// MARK: - Preview

struct CampusSectionView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            CampusSectionView(
                viewStore: ViewStore(Store(
                    initialState: CampusSectionView.ViewState(
                        campusState: .loggedOut,
                        fullName: "",
                        cathedra: ""
                    ),
                    reducer: EmptyReducer()
                ))
            )
            .smallPreview
            .padding(16)
            .background(Color.screenBackground)

            CampusSectionView(
                viewStore: ViewStore(Store(
                    initialState: CampusSectionView.ViewState(
                        campusState: .loggedIn(
                            CampusUserInfo.mock
                        ),
                        fullName: CampusUserInfo.mock.fullName,
                        cathedra: CampusUserInfo.mock.subdivision.first?.name ?? "-"
                    ),
                    reducer: EmptyReducer()
                ))
            )
            .smallPreview
            .padding(16)
            .background(Color.screenBackground)
        }
    }
}
