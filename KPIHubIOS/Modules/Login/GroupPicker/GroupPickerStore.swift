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
        var groups: [GroupResponse]
        var searchedGroups: [GroupResponse]
        @BindableState var searchedText: String
        @BindableState var isLoading: Bool

        init() {
            groups = []
            searchedGroups = []
            searchedText = ""
            isLoading = true
        }
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case onAppear
        case allGroupsResponse(Result<[GroupResponse], APIError>)
        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case selected
        }
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onAppear:
            let task: Effect<[GroupResponse], Error> = Effect.task {
                let result = try await environment.apiClient.request(
                    for: .api(.groups(.all)),
                    as: AllGroupsResponse.self
                )
                return result.groups
            }

            return task
                .mapError(APIError.init(error:))
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.allGroupsResponse)

        case let .allGroupsResponse(.success(groups)):
            state.isLoading = false
            state.groups = groups
            state.searchedGroups = groups
            return .none

        case let .allGroupsResponse(.failure(error)):
            state.isLoading = false
            print("API: \(error)")
            return .none

        case .binding(\.$searchedText):
            if state.searchedText.isEmpty {
                state.searchedGroups = state.groups
            } else {
                let filtered = state.groups.filter { group in
                    let groupName = group.name.lowercased()
                    let searchedText = state.searchedText.lowercased()
                    return groupName.contains(searchedText)
                }
                state.searchedGroups = filtered
            }
            return .none

        case .binding:
            return .none

        case .routeAction:
            return .none
        }
    }
    .binding()

}
