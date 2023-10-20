//
//  ProfileScreenProvider.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture
import ForDevelopersFeature

extension Profile {
    struct ScreenProvider {}
}

extension Profile.ScreenProvider: Reducer {
    enum State: Equatable {
//        case profileHome(ProfileHome.State)
        case forDevelopers(ForDevelopersFeature.State)
    }
    
    enum Action: Equatable {
//        case profileHome(ProfileHome.Action)
        case forDevelopers(ForDevelopersFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
//        Scope(state: /State.profileHome, action: /Action.profileHome) {
//            ProfileHome()
//        }
        Scope(state: /State.forDevelopers, action: /Action.forDevelopers) {
            ForDevelopersFeature()
        }
    }
}
