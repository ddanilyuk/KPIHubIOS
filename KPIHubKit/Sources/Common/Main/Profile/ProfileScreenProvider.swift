//
//  ProfileScreenProvider.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture

extension Profile {
    @Reducer
    public struct Path: Reducer {
        @ObservableState
        public enum State: Equatable {
            case forDevelopers(ForDevelopers.State)
        }
        
        public enum Action: Equatable {
            case forDevelopers(ForDevelopers.Action)
        }
        
        public var body: some ReducerOf<Self> {
            Scope(state: \.forDevelopers, action: \.forDevelopers) {
                ForDevelopers()
            }
        }
    }
}
