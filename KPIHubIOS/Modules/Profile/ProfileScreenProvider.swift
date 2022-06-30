//
//  ProfileScreenProvider.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture

extension Profile {

    struct ScreenProvider {}

}

extension Profile.ScreenProvider {

    // MARK: - State handling

    enum State: Equatable, CoordinatorStateIdentifiable {

        static var module: Any.Type = Profile.self

        case profileHome(ProfileHome.State)
        case forDevelopers(ForDevelopers.State)
    }

    // MARK: - Action handling

    enum Action: Equatable {
        case profileHome(ProfileHome.Action)
        case forDevelopers(ForDevelopers.Action)
    }

    // MARK: - Reducer handling

    static let reducer = Reducer<State, Action, Profile.Environment>.combine(
        ProfileHome.reducer
            .pullback(
                state: /State.profileHome,
                action: /Action.profileHome,
                environment: {
                    ProfileHome.Environment(
                        apiClient: $0.apiClient,
                        userDefaultsClient: $0.userDefaultsClient,
                        rozkladClient: $0.rozkladClient,
                        campusClient: $0.campusClient,
                        currentDateClient: $0.currentDateClient
                    )
                }
            ),
        ForDevelopers.reducer
            .pullback(
                state: /State.forDevelopers,
                action: /Action.forDevelopers,
                environment: { _ in
                    ForDevelopers.Environment()
                }
            )
    )

}
