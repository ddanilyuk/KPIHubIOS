//
//  MainView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct MainTabCoordinatorView: View {

    let store: StoreOf<Main>

    var body: some View {
        WithViewStore(store) { viewStore in
            TabView(selection: viewStore.binding(\.$selectedTab)) {
                RozkladFlowCoordinatorView(
                    store: store.scope(
                        state: \Main.State.rozklad,
                        action: Main.Action.rozklad
                    )
                )
                .tabItem {
                    VStack {
                        Image(systemName: "list.bullet.rectangle")
                        Text("Розклад")
                    }
                }
                .tag(Main.State.Tab.rozklad)

                CampusFlowCoordinatorView(
                    store: store.scope(
                        state: \Main.State.campus,
                        action: Main.Action.campus
                    )
                )
                .tabItem {
                    VStack {
                        Image(systemName: "graduationcap")
                        Text("Кампус")
                    }
                }
                .tag(Main.State.Tab.campus)

                ProfileFlowCoordinatorView(
                    store: store.scope(
                        state: \Main.State.profile,
                        action: Main.Action.profile
                    )
                )
                .tabItem {
                    VStack {
                        Image(systemName: "person")
                        Text("Профіль")
                    }
                }
                .tag(Main.State.Tab.profile)
            }
            .onAppear {
                viewStore.send(.rozklad(.onSetup))
                viewStore.send(.campus(.onSetup))
            }
        }
    }

}
