//
//  AppView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture
import GroupPickerFeature

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    var body: some View {
        switch store.destination {
//        case .groupPicker:
//            if let childStore = store.scope(
//                state: \.destination?.groupPicker,
//                action: \.destination.groupPicker
//            ) {
//                GroupPickerView(store: childStore)
//            }

        case .main:
            if let childStore = store.scope(
                state: \.destination?.main,
                action: \.destination.main
            ) {
                MainFlowView(store: childStore)
            }
            
        case .none:
            EmptyView()
        }
    }
}
