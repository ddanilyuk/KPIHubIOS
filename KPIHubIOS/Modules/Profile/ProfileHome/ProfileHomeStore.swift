//
//  ProfileHomeStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture

struct ProfileHome {

    // MARK: - State

    struct State: Equatable {
        var groupName: String = ""
        var lastUpdated: Date = Date()

        var cathedraName: String = ""
        var name: String = ""
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear

        case setRozkladState(RozkladClient.State)
        case setCampusState(CampusClient.State)

        case changeGroup
        case campusLogout
    }

    // MARK: - Environment

    struct Environment {
        let userDefaultsClient: UserDefaultsClient
        let rozkladClient: RozkladClient
        let campusClient: CampusClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onAppear:
            return .merge(
                Effect.run { subscriber in
                    environment.rozkladClient.stateSubject
                        .sink { rozkladState in
                            subscriber.send(.setRozkladState(rozkladState))
                        }
                },
                Effect.run { subscriber in
                    environment.campusClient.stateSubject
                        .sink { campusState in
                            subscriber.send(.setCampusState(campusState))
                        }
                }
            )

        case let .setRozkladState(rozkladState):
            switch rozkladState {
            case let .selected(group):
                state.groupName = group.name
            case .notSelected:
                state.groupName = "-"
            }
            return .none

        case let .setCampusState(campusState):
            switch campusState {
            case let .loggedIn(campusUserInfo):
                state.cathedraName = campusUserInfo.subdivision.first?.name ?? "-"
                state.name = campusUserInfo.fullName

            case .loggedOut:
                state.cathedraName = "-"
                state.name = "-"
            }
            return .none

        case .changeGroup:
            environment.rozkladClient.logOut()
            return .none

        case .campusLogout:
            environment.campusClient.logOut()
            return .none
        }
    }

}
