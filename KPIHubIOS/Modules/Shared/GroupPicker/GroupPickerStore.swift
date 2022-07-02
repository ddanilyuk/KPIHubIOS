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
        var groups: [GroupResponse] = []
        var searchedGroups: [GroupResponse] = []
        @BindableState var searchedText: String = ""
        @BindableState var isLoading: Bool = true
        var alert: AlertState<Action>?
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case onAppear
        case refresh
        case groupSelected(GroupResponse)

        case allGroupsResult(Result<[GroupResponse], NSError>)
        case lessonsResult(Result<[Lesson], NSError>)

        case dismissAlert
        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case done
        }
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClientable
        let rozkladClient: RozkladClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onAppear:
            return Effect(value: .refresh)

        case let .allGroupsResult(.success(groups)):
            state.isLoading = false
            state.groups = groups
            state.searchedGroups = groups
            return .none

        case .refresh:
            let task: Effect<[GroupResponse], Error> = Effect.task {
                let result = try await environment.apiClient.decodedResponse(
                    for: .api(.groups(.all)),
                    as: GroupsResponse.self
                )
                return result.value.groups
            }
            return task
                .mapError { $0 as NSError }
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.allGroupsResult)

        case let .groupSelected(group):
            state.isLoading = true
            let task: Effect<[Lesson], Error> = Effect.task {
                let result = try await environment.apiClient.decodedResponse(
                    for: .api(.group(group.id, .lessons)),
                    as: LessonsResponse.self
                )
                environment.rozkladClient.state.setState(ClientValue(.selected(group), commitChanges: false))
                return result.value.lessons.map { Lesson(lessonResponse: $0) }
            }
            return task
                .mapError { $0 as NSError }
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.lessonsResult)

        case let .lessonsResult(.success(lessons)):
            state.isLoading = false
            environment.rozkladClient.lessons.set(.init(lessons, commitChanges: false))
            return Effect(value: .routeAction(.done))

        case let .allGroupsResult(.failure(error)),
             let .lessonsResult(.failure(error)):
            state.isLoading = false
            state.alert = AlertState.error(error)
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

        case .dismissAlert:
            state.alert = nil
            return .none

        case .binding:
            return .none

        case .routeAction:
            return .none
        }
    }
    .binding()

}
