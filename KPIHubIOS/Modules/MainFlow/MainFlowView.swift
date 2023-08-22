//
//  MainView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct MainFlowView: View {
    struct ViewState: Equatable {
        @BindingViewState var selectedTab: MainFlow.Tab
        
        init(state: BindingViewStore<MainFlow.State>) {
            _selectedTab = state.$selectedTab
        }
    }
    
    private let store: StoreOf<MainFlow>
    @ObservedObject private var viewStore: ViewStore<ViewState, MainFlow.Action>
    
    init(store: StoreOf<MainFlow>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init)
    }

    var body: some View {
        TabView(selection: viewStore.$selectedTab) {
            RozkladFlowView(
                store: store.scope(
                    state: \.rozklad,
                    action: MainFlow.Action.rozklad
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
                    action: MainFlow.Action.campus
                )
            )
            .tabItem {
                VStack {
                    Image(systemName: "graduationcap")
                    Text("Кампус")
                }
            }
            .tag(MainFlow.Tab.campus)
            
            ProfileFlowCoordinatorView(
                store: store.scope(
                    state: \.profile,
                    action: MainFlow.Action.profile
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
            viewStore.send(.rozklad(.onSetup))
            viewStore.send(.campus(.onSetup))
        }
    }
}
