//
//  CampusSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 07.06.2022.
//

import SwiftUI

struct CampusSectionView: View {

    let campusState: CampusClient.StateModule.State
    let onLogoutCampus: () -> Void
    let onLoginCampus: () -> Void

    var body: some View {
        ProfileSectionView(
            title: "Кампус",
            content: {
                switch campusState {
                case let .loggedIn(campusUserInfo):
                    loggedInView(with: campusUserInfo)
                case .loggedOut:
                    loggedOutView
                }
            }
        )
    }

    func loggedInView(with campusUserInfo: CampusUserInfo) -> some View {
        VStack(alignment: .leading, spacing: 20) {

            ProfileCellView(
                title: "Ім'я:",
                value: .text(campusUserInfo.fullName),
                image: {
                    Image(systemName: "person")
                        .foregroundColor(Color(red: 247 / 255, green: 244 / 255, blue: 255 / 255))
                },
                imageBackgroundColor: Color(red: 91 / 255, green: 46 / 255, blue: 255 / 255)
            )

            ProfileCellView(
                title: "Кафедра:",
                value: .text(campusUserInfo.subdivision.first?.name ?? "-"),
                image: {
                    Image(systemName: "graduationcap")
                        .foregroundColor(Color(red: 237 / 255, green: 246 / 255, blue: 254 / 255))
                },
                imageBackgroundColor: Color(red: 37 / 255, green: 114 / 255, blue: 228 / 255)
            )

            Divider()

            Button(
                action: { onLogoutCampus() },
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
                action: { onLoginCampus() },
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
