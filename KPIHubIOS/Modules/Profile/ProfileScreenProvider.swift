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

extension Profile.ScreenProvider: ReducerProtocol {

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
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: /State.profileHome, action: /Action.profileHome) {
            ProfileHome()
        }
        Scope(state: /State.forDevelopers, action: /Action.forDevelopers) {
            ForDevelopers()
        }
    }

}
