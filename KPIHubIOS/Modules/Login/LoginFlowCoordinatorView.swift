//
//  LoginFlowCoordinatorView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct LoginFlowCoordinatorView: View {
    private let store: StoreOf<Login>
    
    init(store: StoreOf<Login>) {
        self.store = store
    }
    
    var body: some View {
        NavigationStackStore(
            store.scope(state: \.path, action: Login.Action.path),
            root: {
                OnboardingView(
                    store: store.scope(
                        state: \.onboarding,
                        action: Login.Action.onboarding
                    )
                )
            },
            destination: { destination in
                switch destination {
                case .campusLogin:
                    CaseLet(
                        /Login.Path.State.campusLogin,
                        action: Login.Path.Action.campusLogin,
                        then: CampusLoginView.init
                    )
                case .groupPicker:
                    CaseLet(
                        /Login.Path.State.groupPicker,
                        action: Login.Path.Action.groupPicker,
                        then: GroupPickerView.init
                    )
                }
            }
        )
    }
}
