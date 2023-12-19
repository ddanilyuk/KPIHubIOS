//
//  OnboardingFlowView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture
import RozkladKit
import GroupPickerFeature
import CampusLoginFeature

struct OnboardingFlowView: View {
    @Bindable var store: StoreOf<OnboardingFlow>
    
    init(store: StoreOf<OnboardingFlow>) {
        self.store = store
    }
    
    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path),
            root: {
                OnboardingView(store: store.scope(state: \.onboarding, action: \.onboarding))
            },
            destination: { store in
                switch store.withState({ $0 }) {
                case .groupPicker:
                    if let store = store.scope(state: \.groupPicker, action: \.groupPicker) {
                        GroupPickerView(store: store)
                    }
                    
                case .campusLogin:
                    if let store = store.scope(state: \.campusLogin, action: \.campusLogin) {
                        CampusLoginView(store: store)
                    }
                }
            }
        )
    }
}
