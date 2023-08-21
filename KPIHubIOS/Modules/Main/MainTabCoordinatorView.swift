//
//  MainView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct MainTabCoordinatorView: View {
    struct ViewState: Equatable {
        @BindingViewState var selectedTab: Main.Tab
        
        init(state: BindingViewStore<Main.State>) {
            _selectedTab = state.$selectedTab
        }
    }
    
    private let store: StoreOf<Main>
    @ObservedObject private var viewStore: ViewStore<ViewState, Main.Action>
    
    init(store: StoreOf<Main>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }

    var body: some View {
        TabView(selection: viewStore.$selectedTab) {
            RozkladFlowCoordinatorView(
                store: store.scope(
                    state: \.rozklad,
                    action: Main.Action.rozklad
                )
            )
            .tabItem {
                VStack {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Розклад")
                }
            }
            .tag(Main.Tab.rozklad)
            
            CampusFlowCoordinatorView(
                store: store.scope(
                    state: \.campus,
                    action: Main.Action.campus
                )
            )
            .tabItem {
                VStack {
                    Image(systemName: "graduationcap")
                    Text("Кампус")
                }
            }
            .tag(Main.Tab.campus)
            
            ProfileFlowCoordinatorView(
                store: store.scope(
                    state: \.profile,
                    action: Main.Action.profile
                )
            )
            .tabItem {
                VStack {
                    Image(systemName: "person")
                    Text("Профіль")
                }
            }
            .tag(Main.Tab.profile)
        }
        .onAppear {
            viewStore.send(.rozklad(.onSetup))
            viewStore.send(.campus(.onSetup))
        }
    }
}
