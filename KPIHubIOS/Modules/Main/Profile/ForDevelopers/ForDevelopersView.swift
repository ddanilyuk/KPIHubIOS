//
//  ForDevelopersView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct ForDevelopersView: View {
    struct ViewState: Equatable {
        init(state: ForDevelopers.State) { }
    }
    
    @ObservedObject private var viewStore: ViewStore<ViewState, ForDevelopers.Action.View>
    
    init(store: StoreOf<ForDevelopers>) {
        viewStore = ViewStore(store, observe: ViewState.init, send: { .view($0) })
    }
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 32) {
                header

                gitHubSection

                contactsSection
            }
            .padding(16)
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .background(Color.screenBackground)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Для розробників")
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Привіт!")
                .font(.title)

            Text("Цей додаток з відкритим кодом. Вся детальна інформація у README.md в репозиторіях")
            Text("Якщо є будь-які питання, напиши мені.")
        }
    }
    
    private var gitHubSection: some View {
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
                            Image(.github)
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
                            Image(.github)
                                .resizable()
                        },
                        imageBackgroundColor: .white
                    )

                }
            }
        )
    }

    private var contactsSection: some View {
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
                            Image(.telegram)
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
#Preview {
    ForDevelopersView(
        store: Store(
            initialState: ForDevelopers.State()
        ) {
            ForDevelopers()
        }
    )
}
