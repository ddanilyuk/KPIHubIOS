//
//  ForDevelopersView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct ForDevelopersView: View {

    let store: Store<ForDevelopers.State, ForDevelopers.Action>

    var body: some View {
        WithViewStore(store) { _ in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 32) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Привіт!")
                            .font(.title)

                        Text("Цей додаток з відкритим кодом. Вся детальна інформація у README.md в репозиторіях")
                        Text("Якщо є будь-які питанням, напиши мені.")
                    }

                    ProfileSection(
                        title: "Github",
                        content: {
                            VStack(alignment: .leading, spacing: 20) {

                                ProfileHomeViewCell(
                                    title: "Додаток:",
                                    value: .link(
                                        name: "KPIHubIOS",
                                        url: URL(string: "https://github.com/ddanilyuk/KPIHubIOS")!
                                    ),
                                    image: {
                                        Image("github")
                                            .resizable()
                                    },
                                    backgroundColor: .white
                                )

                                ProfileHomeViewCell(
                                    title: "Сервер:",
                                    value: .link(
                                        name: "KPIHubServer",
                                        url: URL(string: "https://github.com/ddanilyuk/KPIHubServer")!
                                    ),
                                    image: {
                                        Image("github")
                                            .resizable()
                                    },
                                    backgroundColor: .white
                                )

                            }
                        }
                    )

                    ProfileSection(
                        title: "Контакти",
                        content: {
                            VStack(alignment: .leading, spacing: 20) {

                                ProfileHomeViewCell(
                                    title: "Telegram:",
                                    value: .link(
                                        name: "@ddanilyuk",
                                        url: URL(string: "https://t.me/ddanilyuk")!
                                    ),
                                    image: {
                                        Image("telegram")
                                            .resizable()
                                    },
                                    backgroundColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
                                )

                                ProfileHomeViewCell(
                                    title: "Email:",
                                    value: .link(
                                        name: "danis.danilyuk@gmail.com",
                                        url: URL(string: "mailto:danis.danilyuk@gmail.com")!
                                    ),
                                    image: {
                                        Image(systemName: "mail")
                                            .foregroundColor(.green.lighter(by: 0.9))
                                    },
                                    backgroundColor: .green
                                )

                            }
                        }
                    )
                }
                .padding(16)
            }
        }
        .background(Color.screenBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Для розробників")
    }

}

// MARK: - Preview

struct ForDevelopersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ForDevelopersView(
                store: Store(
                    initialState: ForDevelopers.State(),
                    reducer: ForDevelopers.reducer,
                    environment: ForDevelopers.Environment()
                )
            )
        }
    }
}
