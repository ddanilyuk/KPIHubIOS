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

        var rozkladState: RozkladClient.State = .notSelected
        var campusState: CampusClient.State = .loggedOut
        
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear

        case setRozkladState(RozkladClient.State)
        case setCampusState(CampusClient.State)

        case changeGroup
        case selectGroup

        case campusLogout
        case campusLogin

        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case rozklad
            case campus
        }
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
            state.rozkladState = rozkladState
            return .none

        case let .setCampusState(campusState):
            state.campusState = campusState
            return .none

        case .changeGroup:
            environment.rozkladClient.logOut()
            return Effect(value: .routeAction(.rozklad))

        case .selectGroup:
            return Effect(value: .routeAction(.rozklad))

        case .campusLogout:
            environment.campusClient.logOut()
            return Effect(value: .routeAction(.campus))

        case .campusLogin:
            return Effect(value: .routeAction(.campus))

        case .routeAction:
            return .none
        }
    }

}
