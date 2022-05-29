//
//  GroupPickerStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import URLRouting

struct GroupPicker {

    // MARK: - State

    struct State: Equatable {
        var groups: [Group]
    }

    // MARK: - Action

    enum Action: Equatable {
        case onAppear
        case allGroupsResponse(Result<[Group], NSError>)
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onAppear:
            let task: Effect<[Group], Error> = Effect.task {
                let result = try await environment.apiClient.decodedResponse(
                    for: .api(.groups(.all)),
                    as: GroupResponse.self
                )
                return result.value.groups
            }
            return task
                .mapError { $0 as NSError }
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.allGroupsResponse)

        case let .allGroupsResponse(.success(groups)):
            state.groups = groups
            return .none

        case let .allGroupsResponse(.failure(error)):
            print(error.localizedDescription)
            return .none
        }

    }

}
