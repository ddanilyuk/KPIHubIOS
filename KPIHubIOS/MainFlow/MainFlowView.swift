//
//  MainView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture
import CampusFeature

@ViewAction(for: MainFlow.self)
struct MainFlowView: View {
    // TODO: Check this view re-render
    @Bindable var store: StoreOf<MainFlow>
    
    init(store: StoreOf<MainFlow>) {
        self.store = store
    }
    
    var body: some View {
        TabView(selection: $store.selectedTab) {
            RozkladFlowView(
                store: store.scope(
                    state: \.rozklad,
                    action: \.rozklad
                )
            )
            .tabItem {
                VStack {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Розклад")
                }
            }
            .tag(MainFlow.Tab.rozklad)
            
            CampusFlowCoordinatorView(
                store: store.scope(
                    state: \.campus,
                    action: \.campus
                )
            )
            .tabItem {
                VStack {
                    Image(systemName: "graduationcap")
                    Text("Кампус")
                }
            }
            .tag(MainFlow.Tab.campus)
//            
            ProfileFlowView(
                store: store.scope(
                    state: \.profile,
                    action: \.profile
                )
            )
            .tabItem {
                VStack {
                    Image(systemName: "person")
                    Text("Профіль")
                }
            }
            .tag(MainFlow.Tab.profile)
        }
        .onAppear {
            send(.onAppear)
        }
    }
}
