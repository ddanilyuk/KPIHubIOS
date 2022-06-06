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
        case groupSelected(GroupResponse)

        case allGroupsResult(Result<[GroupResponse], NSError>)
        case lessonsResult(Result<[Lesson], NSError>)

        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case done
        }
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClient
        let rozkladClient: RozkladClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onAppear:
            let task: Effect<[GroupResponse], Error> = Effect.task {
                let result = try await environment.apiClient.decodedResponse(
                    for: .api(.groups(.all)),
                    as: AllGroupsResponse.self
                )
                return result.value.groups
            }
            return task
                .mapError { $0 as NSError }
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.allGroupsResult)

        case let .allGroupsResult(.success(groups)):
            state.isLoading = false
            state.groups = groups
            state.searchedGroups = groups
            return .none

        case let .groupSelected(group):
            state.isLoading = true
            let task: Effect<[Lesson], Error> = Effect.task {
                let result = try await environment.apiClient.decodedResponse(
                    for: .api(.group(group.id, .lessons)),
                    as: LessonsResponse.self
                )
                environment.userDefaultsClient.set(group, for: .group)
                return result.value.lessons.map { Lesson(lessonResponse: $0) }
            }
            return task
                .mapError { $0 as NSError }
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.lessonsResult)

        case let .lessonsResult(.success(lessons)):
            state.isLoading = false
            environment.rozkladClient.set(lessons: lessons)
            return Effect(value: .routeAction(.done))

        case let .allGroupsResult(.failure(error)),
             let .lessonsResult(.failure(error)):
            state.isLoading = false
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
