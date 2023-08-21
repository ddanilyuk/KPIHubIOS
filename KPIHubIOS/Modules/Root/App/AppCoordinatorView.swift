//
//  AppCoordinatorView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct AppCoordinatorView: View {
    private let store: StoreOf<AppFeature>
    
    init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    var body: some View {
        SwitchStore(store.scope(state: \.path, action: { .path($0) })) { state in
            switch state {
            case .main:
                CaseLet(
                    /AppFeature.Path.State.main,
                    action: AppFeature.Path.Action.main,
                    then: MainTabCoordinatorView.init
                )
                
            case .onboarding:
                CaseLet(
                    /AppFeature.Path.State.onboarding,
                    action: AppFeature.Path.Action.onboarding,
                    then: OnboardingFlowView.init
                )
            }
        }
    }
}
