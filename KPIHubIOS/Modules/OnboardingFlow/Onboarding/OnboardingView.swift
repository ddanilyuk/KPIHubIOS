//
//  OnboardingView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    struct ViewState: Equatable { }
    
    private let store: StoreOf<OnboardingFeature>
    @ObservedObject private var viewStore: ViewStore<ViewState, OnboardingFeature.Action.View>
    @Environment(\.colorScheme) var colorScheme
    
    init(store: StoreOf<OnboardingFeature>) {
        self.store = store
        self.viewStore = ViewStore(
            store,
            observe: { _ in ViewState() },
            send: OnboardingFeature.Action.view
        )
    }
    
    var body: some View {
        VStack {
            ZStack(alignment: .center) {
                colorScheme == .light ? Color.white : Color.black
                
                Image(.kpiHubLogo)
                    .resizable()
                    .frame(width: 200, height: 200, alignment: .center)
                    .shadow(color: .orange.opacity(0.2), radius: 24, x: 0, y: 12)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .ignoresSafeArea()
            
            Color.screenBackground
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .overlay {
                    bottomView
                }
                .ignoresSafeArea()
        }
        .navigationBarHidden(true)
        .background(Color.screenBackground)
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
    
    private var bottomView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 20) {
                Button(
                    "Увійти через кампус",
                    action: {
                        viewStore.send(.loginButtonTapped)
                    }
                )
                
                Button(
                    "Обрати группу",
                    action: {
                        viewStore.send(.selectGroupButtonTapped)
                    }
                )
            }
            .buttonStyle(BigButtonStyle())
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding(20)
        }
        .padding(20)
        .cornerRadius(20)
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingView(
                store: Store(initialState: OnboardingFeature.State()) {
                    OnboardingFeature()
                }
            )
        }
    }
}
