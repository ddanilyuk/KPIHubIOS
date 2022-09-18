//
//  ForDevelopers.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import ComposableArchitecture

struct ForDevelopers: ReducerProtocol {

    // MARK: - State

    struct State: Equatable { }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
    }

    // MARK: - Reducer
    
    @Dependency(\.analyticsClient) var analyticsClient
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                analyticsClient.track(Event.Profile.forDevelopersAppeared)
                return .none
            }
        }
    }

}
