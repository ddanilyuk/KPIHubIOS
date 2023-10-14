//
//  RozkladRoot.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import SwiftUI
import ComposableArchitecture

extension RozkladFlow {
    struct RozkladRoot: Reducer {
        enum State: Equatable {
            case groupRozklad(GroupRozklad.State)
            case groupPicker(GroupPickerFeature.State)
        }
        
        enum Action: Equatable {
            case groupRozklad(GroupRozklad.Action)
            case groupPicker(GroupPickerFeature.Action)
        }

        var body: some ReducerOf<Self> {
            Scope(state: /State.groupRozklad, action: /Action.groupRozklad) {
                GroupRozklad()
            }
            Scope(state: /State.groupPicker, action: /Action.groupPicker) {
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
            SwitchStore(store) { state in
                switch state {
                case .groupRozklad:
                    CaseLet(
                        /RozkladRoot.State.groupRozklad,
                        action: RozkladRoot.Action.groupRozklad,
                        then: GroupRozkladView.init(store:)
                    )
                    
                case .groupPicker:
                    CaseLet(
                        /RozkladRoot.State.groupPicker,
                        action: RozkladRoot.Action.groupPicker,
                        then: GroupPickerView.init(store:)
                    )
                }
            }
        }
    }
}
