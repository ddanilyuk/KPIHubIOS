//
//  ProfileHomeView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct ProfileHomeView: View {
    struct ViewState: Equatable {
        @BindingViewState var isLoading: Bool
        
        init(state: BindingViewStore<ProfileHome.State>) {
            _isLoading = state.$isLoading
        }
    }
    
    private let store: StoreOf<ProfileHome>
    @ObservedObject private var viewStore: ViewStore<ViewState, ProfileHome.Action.View>

    init(store: StoreOf<ProfileHome>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init, send: { .view($0) })
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                RozkladSectionView(store: store)

                CampusSectionView(store: store)
                
                OtherSectionView(store: store)
            }
            .padding(16)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Профіль")
        .onAppear {
            viewStore.send(.onAppear)
        }
        // TODO: assets
//        .background(Color.screenBackground)
        .loadable(viewStore.$isLoading)
        .alert(
            store: store.scope(state: \.$destination, action: { .destination($0) }),
            state: /ProfileHome.Destination.State.alert,
            action: ProfileHome.Destination.Action.alert
        )
        .confirmationDialog(
            store: store.scope(state: \.$destination, action: { .destination($0) }),
            state: /ProfileHome.Destination.State.confirmationDialog,
            action: ProfileHome.Destination.Action.confirmationDialog
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ProfileHomeView(
            store: Store(initialState: ProfileHome.State(
                rozkladState: .notSelected,
                campusState: .loggedOut
            )) {
                ProfileHome()
            }
        )
    }
}

#Preview {
    NavigationStack {
        ProfileHomeView(
            store: Store(initialState: ProfileHome.State(
                rozkladState: .selected(GroupResponse(id: UUID(), name: "ІВ-82", faculty: "ФІОТ")),
                campusState: .loggedIn(CampusUserInfo.mock)
            )) {
                ProfileHome()
            }
        )
    }
}
