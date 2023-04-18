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
    enum State: Equatable {
        case profileHome(ProfileHome.State)
        case forDevelopers(ForDevelopers.State)
    }
    
    enum Action: Equatable {
        case profileHome(ProfileHome.Action)
        case forDevelopers(ForDevelopers.Action)
    }
    
    var body: some ReducerProtocol<State, Action> {
        Scope(state: /State.profileHome, action: /Action.profileHome) {
            ProfileHome()
        }
        Scope(state: /State.forDevelopers, action: /Action.forDevelopers) {
            ForDevelopers()
        }
    }
}
