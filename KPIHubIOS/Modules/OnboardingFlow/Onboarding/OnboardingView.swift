//
//  OnboardingView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {

    @Environment(\.colorScheme) var colorScheme

    let store: StoreOf<OnboardingFeature>

    init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                ZStack(alignment: .center) {
                    colorScheme == .light ? Color.white : Color.black

                    Image("kpiHubLogo")
                        .resizable()
                        .frame(width: 200, height: 200, alignment: .center)
                        .shadow(color: .orange.opacity(0.2), radius: 24, x: 0, y: 12)
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity
                )
                .ignoresSafeArea()

                Rectangle()
                    .fill(Color.screenBackground)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                    .overlay(
                        VStack(spacing: 20) {
                            VStack(spacing: 20) {
                                Button(
                                    "Увійти через кампус",
                                    action: {
                                        viewStore.send(
                                            .routeAction(.campusLogin)
                                        )
                                    }
                                )

                                Button(
                                    "Обрати группу",
                                    action: {
                                        viewStore.send(
                                            .routeAction(.groupPicker)
                                        )
                                    }
                                )
                            }
                            .buttonStyle(BigButtonStyle())
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding(20)
                        }
                        .padding(20)
                        .cornerRadius(20)
                    )
                    .ignoresSafeArea()
            }
            .navigationBarHidden(true)
            .background(Color.screenBackground)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }

}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingView(
                store: Store(
                    initialState: OnboardingFeature.State(),
                    reducer: OnboardingFeature()
                )
            )
        }
    }
}
