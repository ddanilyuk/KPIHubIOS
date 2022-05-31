//
//  MainView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct MainTabCoordinatorView: View {

    let store: Store<Main.State, Main.Action>

    var body: some View {
        WithViewStore(store) { _ in
            TabView {
                RozkladFlowCoordinatorView(
                    store: store.scope(
                        state: \Main.State.rozklad,
                        action: Main.Action.rozklad
                    )
                )
                .tabItem {
                    VStack {
                        Image(systemName: "list.bullet.rectangle")
                        Text("Rozklad")
                    }
                }

                CampusFlowCoordinatorView(
                    store: store.scope(
                        state: \Main.State.campus,
                        action: Main.Action.campus
                    )
                )
                .tabItem {
                    VStack {
                        Image(systemName: "graduationcap")
                        Text("Campus")
                    }
                }

                ProfileFlowCoordinatorView(
                    store: store.scope(
                        state: \Main.State.profile,
                        action: Main.Action.profile
                    )
                )
                .tabItem {
                    VStack {
                        Image(systemName: "person")
                        Text("Profile")
                    }
                }

            }
        }
    }

}
