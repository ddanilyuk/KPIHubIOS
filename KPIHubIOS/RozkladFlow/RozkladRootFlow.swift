//
//  RozkladRootFlow.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture
import GroupPickerFeature
import RozkladFeature
import Services
import DesignKit

@Reducer
struct RozkladRootFlow: Reducer {
    @ObservableState
    enum State: Equatable {
        case groupRozklad(RozkladFeature.State)
        case groupPicker(GroupPickerFeature.State)
    }
    
    enum Action {
        case groupRozklad(RozkladFeature.Action)
        case groupPicker(GroupPickerFeature.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.groupRozklad, action: \.groupRozklad) {
            RozkladFeature()
        }
        Scope(state: \.groupPicker, action: \.groupPicker) {
            GroupPickerFeature()
        }
    }
}

import SwiftUI

struct RozkladRootView: View {
    private let store: StoreOf<RozkladRootFlow>
    
    init(store: StoreOf<RozkladRootFlow>) {
        self.store = store
    }
    
    var body: some View {
        switch store.withState({ $0 }) {
        case .groupRozklad:
            if let childStore = store.scope(state: \.groupRozklad, action: \.groupRozklad) {
                RozkladView(store: childStore) { cellStore in
                    RozkladLessonView(store: cellStore)
                }
            }
            
        case .groupPicker:
            if let childStore = store.scope(state: \.groupPicker, action: \.groupPicker) {
                GroupPickerView(store: childStore)
            }
        }
    }
}
