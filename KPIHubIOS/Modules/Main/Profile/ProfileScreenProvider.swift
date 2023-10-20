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

extension Profile.ScreenProvider: Reducer {
    enum State: Equatable {
        case forDevelopers(ForDevelopers.State)
    }
    
    enum Action: Equatable {
        case forDevelopers(ForDevelopers.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.forDevelopers, action: /Action.forDevelopers) {
            ForDevelopers()
        }
    }
}
