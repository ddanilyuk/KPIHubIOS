//
//  GroupPickerStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import ComposableArchitecture
import URLRouting
import Foundation

struct GroupPicker: ReducerProtocol {

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
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.analyticsClient) var analyticsClient

    // MARK: - Reducer

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                analyticsClient.track(Event.Onboarding.groupPickerAppeared)
                return Effect(value: .refresh)

            case let .allGroupsResult(.success(groups)):
                state.isLoading = false
                state.groups = groups
                state.searchedGroups = groups
                analyticsClient.track(Event.Onboarding.groupsLoadSuccess)
                return .none

            case .refresh:
                let task: EffectPublisher<[GroupResponse], Error> = EffectPublisher.task {
                    let result = try await apiClient.decodedResponse(
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
                let task: EffectPublisher<[Lesson], Error> = EffectPublisher.task {
                    let result = try await apiClient.decodedResponse(
                        for: .api(.group(group.id, .lessons)),
                        as: LessonsResponse.self
                    )
                    rozkladClientState.setState(ClientValue(.selected(group), commitChanges: false))
                    return result.value.lessons.map { Lesson(lessonResponse: $0) }
                }
                analyticsClient.setGroup(group)
                analyticsClient.track(Event.Onboarding.groupPickerSelect)
                return task
                    .mapError { $0 as NSError }
                    .receive(on: DispatchQueue.main)
                    // Make keyboard hide to prevent tabBar opacity bugs
                    .delay(for: 0.3, scheduler: DispatchQueue.main)
                    .catchToEffect(Action.lessonsResult)

            case let .lessonsResult(.success(lessons)):
                state.isLoading = false
                rozkladClientLessons.set(.init(lessons, commitChanges: false))
                let place = analyticsLessonsLoadPlace(from: state.mode)
                analyticsClient.track(Event.Rozklad.lessonsLoadSuccess(place: place))
                return Effect(value: .routeAction(.done))

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

}
