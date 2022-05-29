//
//  LoginScreenProvider.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import TCACoordinators

protocol Routable {

    associatedtype ID
    associatedtype ScreenProvider: Equatable & Identifiable
    associatedtype RouteState: Equatable

    static var id: ID { get }
    static var statePath: CasePath<ScreenProvider, RouteState> { get }
}

extension Routable {
    static var id: String {
        return String(describing: self)
    }
}


extension Login {

    struct ScreenProvider {}

}

extension Login.ScreenProvider {

    // MARK: - Routes

    struct OnboardingRoute: Routable {
        static var statePath = /State.onboarding
    }

    struct GroupPickerRoute: Routable {
        static var statePath = /State.groupPicker
    }

    // MARK: - State handling

    enum State: Equatable, Identifiable {
        case onboarding(Onboarding.State)
        case groupPicker(GroupPicker.State)

        var id: String {
            switch self {
            case .onboarding:
                return OnboardingRoute.id
            case .groupPicker:
                return GroupPickerRoute.id
            }
        }
    }

    // MARK: - Action handling

    enum Action: Equatable {
        case onboarding(Onboarding.Action)
        case groupPicker(GroupPicker.Action)
    }

    // MARK: - Reducer handling

    static let reducer = Reducer<State, Action, Login.Environment>.combine(
        Onboarding.reducer
            .pullback(
                state: /State.onboarding,
                action: /Action.onboarding,
                environment: { _ in Onboarding.Environment() }
            ),
        GroupPicker.reducer
            .pullback(
                state: /State.groupPicker,
                action: /Action.groupPicker,
                environment: {
                    GroupPicker.Environment(
                        apiClient: $0.apiClient
                    )
                }
            )
    )

}
