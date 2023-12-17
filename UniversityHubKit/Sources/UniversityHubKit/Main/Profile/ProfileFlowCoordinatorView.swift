//
//  ProfileFlowCoordinatorView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

//import SwiftUI
//import ComposableArchitecture
//
//struct ProfileFlowCoordinatorView: View {
//    @Bindable private var store: StoreOf<Profile>
//    
//    init(store: StoreOf<Profile>) {
//        self.store = store
//    }
//
//    var body: some View {
//        NavigationStack(
//            path: $store.scope(state: \.path, action: \.path),
//            root: {
//                ProfileHomeView(
//                    store: store.scope(
//                        state: \.profileHome,
//                        action: \.profileHome
//                    )
//                )
//            },
//            destination: { store in
//                switch store.withState({ $0 }) {
//                case .forDevelopers:
//                    if let store = store.scope(state: \.forDevelopers, action: \.forDevelopers) {
//                        ForDevelopersView(store: store)
//                    }
//                }
//            }
//        )
//    }
//}
