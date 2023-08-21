//
//  OnboardingFlowView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingFlowView: View {
    private let store: StoreOf<OnboardingFlow>
    
    init(store: StoreOf<OnboardingFlow>) {
        self.store = store
    }
    
    var body: some View {
        NavigationStackStore(
            store.scope(state: \.path, action: OnboardingFlow.Action.path),
            root: {
                OnboardingView(
                    store: store.scope(
                        state: \.onboarding,
                        action: OnboardingFlow.Action.onboarding
                    )
                )
            },
            destination: { destination in
                switch destination {
                case .campusLogin:
                    CaseLet(
                        /OnboardingFlow.Path.State.campusLogin,
                        action: OnboardingFlow.Path.Action.campusLogin,
                        then: CampusLoginView.init
                    )
                case .groupPicker:
                    CaseLet(
                        /OnboardingFlow.Path.State.groupPicker,
                        action: OnboardingFlow.Path.Action.groupPicker,
                        then: GroupPickerView.init
                    )
                }
            }
        )
    }
}
