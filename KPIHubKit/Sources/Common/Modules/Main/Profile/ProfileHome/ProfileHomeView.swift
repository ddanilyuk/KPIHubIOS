//
//  ProfileHomeView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI
import ComposableArchitecture
import Services // TODO: ?

@ViewAction(for: ProfileHome.self)
struct ProfileHomeView: View {
    @Bindable var store: StoreOf<ProfileHome>

    init(store: StoreOf<ProfileHome>) {
        self.store = store
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
            send(.onAppear)
        }
        // TODO: assets
//        .background(Color.screenBackground)
        .loadable($store.isLoading)
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        .confirmationDialog($store.scope(state: \.destination?.confirmationDialog, action: \.destination.confirmationDialog))
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
