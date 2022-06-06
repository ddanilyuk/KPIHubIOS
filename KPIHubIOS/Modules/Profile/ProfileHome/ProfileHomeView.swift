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
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)

                        VStack(alignment: .leading, spacing: 20) {
                            Text("Розклад")
                                .font(.system(.body).bold())

                            VStack(alignment: .leading, spacing: 20) {

                                ProfileHomeViewCell(
                                    title: "Обрана группа:",
                                    value: .text(viewStore.groupName),
                                    imageName: "person.2",
                                    backgroundColor: Color(red: 254 / 255, green: 251 / 255, blue: 232 / 255),
                                    accentColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
                                )


                                Divider()

                                Button(
                                    action: { viewStore.send(.changeGroup) },
                                    label: {
                                        Text("Змінити групу")
                                            .font(.system(.body).bold())
                                            .foregroundColor(.red)

                                        Spacer()
                                    }
                                )
                            }
                        }
                        .padding()
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)

                        VStack(alignment: .leading, spacing: 20) {
                            Text("Кампус")
                                .font(.system(.body).bold())

                            VStack(alignment: .leading, spacing: 20) {

                                ProfileHomeViewCell(
                                    title: "Ім'я:",
                                    value: .text(viewStore.name),
                                    imageName: "person",
                                    backgroundColor: Color(red: 247 / 255, green: 244 / 255, blue: 255 / 255),
                                    accentColor: Color(red: 91 / 255, green: 46 / 255, blue: 255 / 255)
                                )

                                ProfileHomeViewCell(
                                    title: "Кафедра:",
                                    value: .text(viewStore.cathedraName),
                                    imageName: "graduationcap",
                                    backgroundColor: Color(red: 237 / 255, green: 246 / 255, blue: 254 / 255),
                                    accentColor: Color(red: 37 / 255, green: 114 / 255, blue: 228 / 255)
                                )

                                Divider()

                                Button(
                                    action: { viewStore.send(.campusLogout) },
                                    label: {
                                        Text("Вийти з аккаунту")
                                            .font(.system(.body).bold())
                                            .foregroundColor(.red)

                                        Spacer()
                                    }
                                )
                            }
                        }
                        .padding()
                    }
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
                        groupName: "ІВ-82",
                        lastUpdated: Date(),
                        cathedraName: "Кафедра обчислювальної техніки ФІОТ",
                        name: "Данилюк Денис Андрійович"
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
