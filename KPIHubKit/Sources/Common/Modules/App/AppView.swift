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
            
        case .main:
            if let mainStore = store.scope(
                state: \.destination?.main,
                action: \.destination.main
            ) {
                MainFlowView(store: mainStore)
            }
            
        case .none:
            EmptyView()
        }
    }
}
