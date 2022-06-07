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
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)

            VStack(alignment: .leading, spacing: 20) {
                Text("Кампус")
                    .font(.system(.body).bold())
                switch campusState {
                case let .loggedIn(campusUserInfo):
                    loggedInView(with: campusUserInfo)
                case .loggedOut:
                    loggedOutView
                }
            }
            .padding()
        }
    }

    func loggedInView(with campusUserInfo: CampusUserInfo) -> some View {
        VStack(alignment: .leading, spacing: 20) {

            ProfileHomeViewCell(
                title: "Ім'я:",
                value: .text(campusUserInfo.fullName),
                imageName: "person",
                backgroundColor: Color(red: 247 / 255, green: 244 / 255, blue: 255 / 255),
                accentColor: Color(red: 91 / 255, green: 46 / 255, blue: 255 / 255)
            )

            ProfileHomeViewCell(
                title: "Кафедра:",
                value: .text(campusUserInfo.subdivision.first?.name ?? "-"),
                imageName: "graduationcap",
                backgroundColor: Color(red: 237 / 255, green: 246 / 255, blue: 254 / 255),
                accentColor: Color(red: 37 / 255, green: 114 / 255, blue: 228 / 255)
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
