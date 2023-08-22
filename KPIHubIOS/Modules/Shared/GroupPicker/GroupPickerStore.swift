//
//  GroupPickerStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import URLRouting
import Foundation

struct GroupPickerFeature: Reducer {
    struct State: Equatable {
        let mode: Mode
        var groups: [GroupResponse] = []
        var searchedGroups: [GroupResponse] = []
        var selectedGroup: GroupResponse?
        @BindingState var searchedText: String = ""
        @BindingState var isLoading: Bool = true
        @PresentationState var alert: AlertState<Action.Alert>?
    }
    
    enum Action: Equatable {
        case allGroupsResult(TaskResult<[GroupResponse]>)
        case lessonsResult(TaskResult<[Lesson]>)
        
        case route(Route)
        case alert(PresentationAction<Alert>)
        case view(View)
        
        enum Route: Equatable {
            case done
        }
        
        enum Alert: Equatable { }
        
        enum View: BindableAction, Equatable {
            case onAppear
            case refresh
            case groupSelected(GroupResponse)
            case binding(BindingAction<State>)
        }
    }

    @Dependency(\.apiService) var apiClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.analyticsClient) var analyticsClient
    
    var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
            case let .allGroupsResult(.success(groups)):
                state.isLoading = false
                state.groups = groups
                state.searchedGroups = groups
                analyticsClient.track(Event.Onboarding.groupsLoadSuccess)
                return .none

            case let .lessonsResult(.success(lessons)):
                if let selectedGroup = state.selectedGroup {
                    rozkladClientState.setState(ClientValue(.selected(selectedGroup), commitChanges: false))
                    analyticsClient.setGroup(selectedGroup)
                }
                state.isLoading = false
                rozkladClientLessons.set(.init(lessons, commitChanges: false))
                let place = analyticsLessonsLoadPlace(from: state.mode)
                analyticsClient.track(Event.Rozklad.lessonsLoadSuccess(place: place))
                return .send(.route(.done))

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

            case .route:
                return .none
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: /Action.alert)
    }
}

// MARK: Analytics
private extension GroupPickerFeature {
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
}

// MARK: API
private extension GroupPickerFeature {
    func loadGroups() -> Effect<Action> {
        .run { send in
            let taskResult = await TaskResult {
                try await apiClient
                    .decodedResponse(
                        for: .api(.groups(.all)),
                        as: GroupsResponse.self
                    )
                    .value.groups
            }
            await send(.allGroupsResult(taskResult))
        }
    }
    
    func getLessons(for group: GroupResponse) -> Effect<Action> {
        .run { send in
            let taskResult = await TaskResult {
                let decodedResponse = try await apiClient.decodedResponse(
                    for: .api(.group(group.id, .lessons)),
                    as: LessonsResponse.self
                )
                return decodedResponse.value.lessons.map(Lesson.init)
            }
            // Make keyboard hide to prevent tabBar opacity bugs
            try await Task.sleep(for: .milliseconds(300))
            await send(.lessonsResult(taskResult))
        }
    }
}

// MARK: View
private extension GroupPickerFeature {
    func handleViewAction(state: inout State, action: Action.View) -> Effect<Action> {
        switch action {
        case .onAppear:
            analyticsClient.track(Event.Onboarding.groupPickerAppeared)
            return loadGroups()
            
        case .refresh:
            return loadGroups()
            
        case let .groupSelected(group):
            state.isLoading = true
            state.selectedGroup = group
            analyticsClient.track(Event.Onboarding.groupPickerSelect)
            return getLessons(for: group)
            
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
        }
    }
}

// MARK: Helper models
extension GroupPickerFeature {
    enum Mode {
        case onboarding
        case rozkladTab
        case campus
    }
}
