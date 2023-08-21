//
//  GroupPickerStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import URLRouting
import Foundation

struct GroupPicker: Reducer {

    // MARK: - State
    
    enum Mode {
        case onboarding
        case rozkladTab
        case campus
    }

    struct State: Equatable {
        let mode: Mode
        var groups: [GroupResponse] = []
        var searchedGroups: [GroupResponse] = []
        @BindingState var searchedText: String = ""
        @BindingState var isLoading: Bool = true
        var alert: AlertState<Action>?
        var selectedGroup: GroupResponse?
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case onAppear
        case refresh
        case groupSelected(GroupResponse)

        case allGroupsResult(TaskResult<[GroupResponse]>)
        case lessonsResult(TaskResult<[Lesson]>)

        case dismissAlert
        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case done
        }
    }

    // MARK: - Environment
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.analyticsClient) var analyticsClient

    // MARK: - Reducer

    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                analyticsClient.track(Event.Onboarding.groupPickerAppeared)
                return loadGroups()
                
            case .refresh:
                return loadGroups()

            case let .allGroupsResult(.success(groups)):
                state.isLoading = false
                state.groups = groups
                state.searchedGroups = groups
                analyticsClient.track(Event.Onboarding.groupsLoadSuccess)
                return .none

            case let .groupSelected(group):
                state.isLoading = true
                state.selectedGroup = group
                analyticsClient.track(Event.Onboarding.groupPickerSelect)
                return .task {
                    let taskResult = await TaskResult {
                        let decodedResponse = try await apiClient.decodedResponse(
                            for: .api(.group(group.id, .lessons)),
                            as: LessonsResponse.self
                        )
                        let lessons = decodedResponse.value.lessons.map { Lesson(lessonResponse: $0) }
                        return lessons
                    }
                    // Make keyboard hide to prevent tabBar opacity bugs
                    try await Task.sleep(for: .milliseconds(300))
                    return .lessonsResult(taskResult)
                }

            case let .lessonsResult(.success(lessons)):
                if let selectedGroup = state.selectedGroup {
                    rozkladClientState.setState(ClientValue(.selected(selectedGroup), commitChanges: false))
                    analyticsClient.setGroup(selectedGroup)
                }
                state.isLoading = false
                rozkladClientLessons.set(.init(lessons, commitChanges: false))
                let place = analyticsLessonsLoadPlace(from: state.mode)
                analyticsClient.track(Event.Rozklad.lessonsLoadSuccess(place: place))
                return .send(.routeAction(.done))

            case let .allGroupsResult(.failure(error)):
                state.isLoading = false
                state.alert = AlertState.error(error)
                analyticsClient.track(Event.Onboarding.groupsLoadFailed)
                return .none
                
            case let .lessonsResult(.failure(error)):
                state.isLoading = false
                state.alert = AlertState.error(error)
                let place = analyticsLessonsLoadPlace(from: state.mode)
                analyticsClient.track(Event.Rozklad.lessonsLoadFailed(place: place))
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
        ._printChanges()
    }
    
    func analyticsLessonsLoadPlace(from mode: Mode) -> Event.Rozklad.Place {
        switch mode {
        case .onboarding:
            return .onboarding
        case .rozkladTab:
            return .rozkladTab
        case .campus:
            return .campusUserInput
        }
    }
    
    func loadGroups() -> Effect<Action> {
        .task {
            let taskResult = await TaskResult {
                try await apiClient
                    .decodedResponse(
                        for: .api(.groups(.all)),
                        as: GroupsResponse.self
                    )
                    .value.groups
            }
            return .allGroupsResult(taskResult)
        }
    }

}
