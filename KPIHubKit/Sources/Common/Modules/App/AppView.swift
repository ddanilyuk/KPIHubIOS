//
//  AppView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

public struct AppView: View {
    private let store: StoreOf<AppFeature>
    
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        switch store.destination {
        case .onboarding:
            if let onboardingStore = store.scope(
                state: \.destination?.onboarding,
                action: \.destination.onboarding
            ) {
                OnboardingFlowView(store: onboardingStore)
            }
            
        case .none:
            EmptyView()
        }

//        IfLetStore(store.scope(state: \.path, action: { .path($0) })) { store in
//            SwitchStore(store) { state in
//                switch state {
//                case .main:
//                    CaseLet(
//                        /AppFeature.Path.State.main,
//                        action: AppFeature.Path.Action.main,
//                        then: MainFlowView.init
//                    )
//
//                case .onboarding:
//                    CaseLet(
//                        /AppFeature.Path.State.onboarding,
//                        action: AppFeature.Path.Action.onboarding,
//                        then: OnboardingFlowView.init
//                    )
//                }
//            }
//        }
    }
}
