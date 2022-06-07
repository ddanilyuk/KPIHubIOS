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

        var rozkladState: RozkladClient.StateModule.State = .notSelected
        var campusState: CampusClient.StateModule.State = .loggedOut
        
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear

        case setRozkladState(RozkladClient.StateModule.State)
        case setCampusState(CampusClient.StateModule.State)

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
                    environment.rozkladClient.state.subject
                        .sink { rozkladState in
                            subscriber.send(.setRozkladState(rozkladState))
                        }
                },
                Effect.run { subscriber in
                    environment.campusClient.state.subject
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
            environment.rozkladClient.state.deselect(commitChanges: true)
            return Effect(value: .routeAction(.rozklad))

        case .selectGroup:
            return Effect(value: .routeAction(.rozklad))

        case .campusLogout:
            environment.campusClient.state.logOut(commitChanges: true)
            environment.campusClient.studySheet.removeLoaded()
            return Effect(value: .routeAction(.campus))

        case .campusLogin:
            return Effect(value: .routeAction(.campus))

        case .routeAction:
            return .none
        }
    }

}
