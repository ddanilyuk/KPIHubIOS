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
            VStack {
                Text("Onboarding")
                Button(
                    "Обрати группу",
                    action: {
                        viewStore.send(.pickGroup)
                    }
                )
            }
        }
    }

}
