//
//  OnboardingView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture
import DesignKit

@ViewAction(for: OnboardingFeature.self)
public struct OnboardingView: View {
    public let store: StoreOf<OnboardingFeature>
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.designKit) var designKit
    
    public init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            ZStack(alignment: .center) {
                colorScheme == .light ? Color.white : Color.black
                
                designKit.logoImage
                    .resizable()
                    .frame(width: 200, height: 200, alignment: .center)
                    .shadow(color: .orange.opacity(0.2), radius: 24, x: 0, y: 12)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .ignoresSafeArea()
            
            designKit.primaryColor
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
        .onAppear {
            send(.onAppear)
        }
        .background(designKit.backgroundColor)
    }
    
    private var bottomView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 20) {
                Button(
                    "Увійти через кампус",
                    action: {
                        send(.loginButtonTapped)
                    }
                )
                
                Button(
                    "Обрати группу",
                    action: {
                        send(.selectGroupButtonTapped)
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
#Preview {
    OnboardingView(store: Store(initialState: OnboardingFeature.State()) {
        OnboardingFeature()
    })
}
