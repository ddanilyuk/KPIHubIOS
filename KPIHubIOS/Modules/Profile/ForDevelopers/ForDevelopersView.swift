//
//  ForDevelopersView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct ForDevelopersView: View {

    let store: StoreOf<ForDevelopers>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 32) {

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Привіт!")
                            .font(.title)

                        Text("Цей додаток з відкритим кодом. Вся детальна інформація у README.md в репозиторіях")
                        Text("Якщо є будь-які питанням, напиши мені.")
                    }

                    gitHubSection

                    contactsSection
                }
                .padding(16)
            }
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
        .background(Color.screenBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Для розробників")
    }

    var gitHubSection: some View {
        ProfileSectionView(
            title: "Github",
            content: {
                VStack(alignment: .leading, spacing: 20) {

                    ProfileCellView(
                        title: "Додаток:",
                        value: .link(
                            name: "KPIHubIOS",
                            url: URL(string: "https://github.com/ddanilyuk/KPIHubIOS")!
                        ),
                        image: {
                            Image("github")
                                .resizable()
                        },
                        imageBackgroundColor: .white
                    )

                    ProfileCellView(
                        title: "Сервер:",
                        value: .link(
                            name: "KPIHubServer",
                            url: URL(string: "https://github.com/ddanilyuk/KPIHubServer")!
                        ),
                        image: {
                            Image("github")
                                .resizable()
                        },
                        imageBackgroundColor: .white
                    )

                }
            }
        )
    }

    var contactsSection: some View {
        ProfileSectionView(
            title: "Контакти",
            content: {
                VStack(alignment: .leading, spacing: 20) {

                    ProfileCellView(
                        title: "Telegram:",
                        value: .link(
                            name: "@ddanilyuk",
                            url: URL(string: "https://t.me/ddanilyuk")!
                        ),
                        image: {
                            Image("telegram")
                                .resizable()
                        },
                        imageBackgroundColor: Color.yellow
                    )

                    ProfileCellView(
                        title: "Email:",
                        value: .link(
                            name: "danis.danilyuk@gmail.com",
                            url: URL(string: "mailto:danis.danilyuk@gmail.com")!
                        ),
                        image: {
                            Image(systemName: "mail")
                                .foregroundColor(.green.lighter(by: 0.9))
                        },
                        imageBackgroundColor: .green
                    )

                }
            }
        )
    }

}

// MARK: - Preview

struct ForDevelopersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ForDevelopersView(
                store: Store(
                    initialState: ForDevelopers.State(),
                    reducer: ForDevelopers()
                )
            )
        }
    }
}
