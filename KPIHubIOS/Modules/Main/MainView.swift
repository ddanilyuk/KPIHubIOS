//
//  MainView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct MainView: View {

    let store: Store<Main.State, Main.Action>

    var body: some View {
        WithViewStore(store) { _ in
            TabView {
                RozkladView(
                    store: store.scope(
                        state: \Main.State.rozklad,
                        action: Main.Action.rozklad
                    )
                )
                .tabItem {
                    Text("Rozklad")
                }

                CampusView(
                    store: store.scope(
                        state: \Main.State.campus,
                        action: Main.Action.campus
                    )
                )
                .tabItem {
                    Text("Campus")
                }

                ProfileView(
                    store: store.scope(
                        state: \Main.State.profile,
                        action: Main.Action.profile
                    )
                )
                .tabItem {
                    Text("Profile")
                }

            }
        }
    }

}
