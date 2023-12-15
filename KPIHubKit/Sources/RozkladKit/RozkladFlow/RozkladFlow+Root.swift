//
//  RozkladRoot.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import SwiftUI
import ComposableArchitecture

extension RozkladFlow {
    @Reducer
    public struct RozkladRoot: Reducer {
        @ObservableState
        public enum State: Equatable {
            case groupRozklad(GroupRozklad.State)
            case groupPicker(GroupPickerFeature.State)
        }
        
        public enum Action: Equatable {
            case groupRozklad(GroupRozklad.Action)
            case groupPicker(GroupPickerFeature.Action)
        }

        public var body: some ReducerOf<Self> {
            Scope(state: \.groupRozklad, action: \.groupRozklad) {
                GroupRozklad()
            }
            Scope(state: \.groupPicker, action: \.groupPicker) {
                GroupPickerFeature()
            }
        }
    }

    struct RozkladRootView: View {
        private let store: StoreOf<RozkladRoot>
        
        init(store: StoreOf<RozkladRoot>) {
            self.store = store
        }
        
        var body: some View {
            switch store.withState({$0}) {
            case .groupRozklad:
                if let childStore = store.scope(state: \.groupRozklad, action: \.groupRozklad) {
                    GroupRozkladView(store: childStore)
                }
                
            case .groupPicker:
                if let childStore = store.scope(state: \.groupPicker, action: \.groupPicker) {
                    GroupPickerView(store: childStore)
                }
            }
        }
    }
}
