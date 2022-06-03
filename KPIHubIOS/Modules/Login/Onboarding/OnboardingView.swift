//
//  OnboardingView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {

    let store: Store<Onboarding.State, Onboarding.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 20) {
                Text("Onboarding")

                Spacer()

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
        }
    }

}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingView(
                store: Store(
                    initialState: Onboarding.State(),
                    reducer: Onboarding.reducer,
                    environment: Onboarding.Environment()
                )
            )
        }
    }
}
