//
//  CampusLoginStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 03.06.2022.
//

import ComposableArchitecture
import Routes
import Foundation

struct CampusLogin: ReducerProtocol {

    // MARK: - State

    struct State: Equatable {

        // MARK: - Mode

        enum Mode {
            case onlyCampus
            case campusAndGroup
        }

        // MARK: - Field

        enum Field: Int, CaseIterable {
            case username
            case password
        }

        // MARK: - Properties

        @BindableState var focusedField: Field?
        @BindableState var username: String = ""
        @BindableState var password: String = ""
        @BindableState var isLoading: Bool = false

        var loginButtonEnabled: Bool = false

        var alert: AlertState<Action>?
        let mode: Mode
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case onAppear
        case login
        case campusUserInfoResult(Result<CampusUserInfo, APIError>)
        case groupSearchResult(Result<GroupResponse, APIError>)
        case lessonsResult(Result<[Lesson], NSError>)

        case dismissAlert
        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction {
            case groupPicker
            case done
        }
    }

    // MARK: - Environment
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.campusClientState) var campusClientState
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.analyticsClient) var analyticsClient

    // MARK: - Reducer

    var body: some ReducerProtocol<State, Action> {
        BindingReducer()

        Reduce { state, action in
            switch action {
            case .onAppear:
                analyticsClient.track(Event.Onboarding.campusLoginAppeared)
                return .none

            case .binding(\.$username):
                state.loginButtonEnabled = !state.username.isEmpty && !state.password.isEmpty
                return .none

            case .binding(\.$password):
                state.loginButtonEnabled = !state.username.isEmpty && !state.password.isEmpty
                return .none

            case .login:
                let campusLoginQuery = CampusLoginQuery(
                    username: state.username,
                    password: state.password
                )
                state.focusedField = nil
                state.isLoading = true
                analyticsClient.track(Event.Onboarding.campusLogin)
                let task: Effect<CampusUserInfo, Error> = Effect.task {
                    let result = try await apiClient.request(
                        for: .api(.campus(.userInfo(campusLoginQuery))),
                        as: CampusUserInfo.self
                    )
                    return result
                }
                return task
                    .mapError(APIError.init(error:))
                    .receive(on: DispatchQueue.main)
                    // Make keyboard hide to prevent tabBar opacity bugs
                    .delay(for: 0.3, scheduler: DispatchQueue.main)
                    .catchToEffect(Action.campusUserInfoResult)

            case let .campusUserInfoResult(.success(campusUserInfo)):
                let groupSearchQuery = GroupSearchQuery(
                    groupName: campusUserInfo.studyGroup.name
                )
                /// Saving credentials after finding group
                let campusCredentials = CampusCredentials(
                    username: state.username,
                    password: state.password
                )
                campusClientState.login(
                    ClientValue(
                        CampusClientState.LoginRequest(
                            credentials: campusCredentials,
                            userInfo: campusUserInfo
                        ),
                        commitChanges: false
                    )
                )
                analyticsClient.setUserProperty(
                    UserProperty.cathedra(campusUserInfo.subdivision.first?.name)
                )
                analyticsClient.track(Event.Onboarding.campusUserLoadSuccess)

                switch state.mode {
                case .onlyCampus:
                    return Effect(value: .routeAction(.done))

                case .campusAndGroup:
                    let task: Effect<GroupResponse, Error> = Effect.task {
                        let result = try await apiClient.request(
                            for: .api(.groups(.search(groupSearchQuery))),
                            as: GroupResponse.self
                        )
                        return result
                    }
                    return task
                        .mapError(APIError.init(error:))
                        .receive(on: DispatchQueue.main)
                        .catchToEffect(Action.groupSearchResult)
                }

            case let .groupSearchResult(.success(group)):
                analyticsClient.setGroup(group)
                analyticsClient.track(Event.Onboarding.campusUserGroupFound)
                let task: Effect<[Lesson], Error> = Effect.task {
                    let result = try await apiClient.decodedResponse(
                        for: .api(.group(group.id, .lessons)),
                        as: LessonsResponse.self
                    )
                    rozkladClientState.setState(ClientValue(.selected(group), commitChanges: false))
                    return result.value.lessons.map { Lesson(lessonResponse: $0) }
                }
                return task
                    .mapError { $0 as NSError }
                    .receive(on: DispatchQueue.main)
                    .catchToEffect(Action.lessonsResult)

            case let .lessonsResult(.success(lessons)):
                rozkladClientLessons.set(.init(lessons, commitChanges: true))
                analyticsClient.track(Event.Rozklad.lessonsLoadSuccess(place: .campus))
                return Effect(value: .routeAction(.done))

            case let .groupSearchResult(.failure(error)):
                state.isLoading = false
                switch error {
                case .serviceError(404, _):
                    analyticsClient.track(Event.Onboarding.campusUserGroupNotFound)
                    return Effect(value: .routeAction(.groupPicker))

                case .serviceError,
                     .unknown:
                    analyticsClient.track(Event.Onboarding.campusUserGroupFailed)
                    return .none
                }

            case let .campusUserInfoResult(.failure(error)):
                state.isLoading = false
                switch error {
                case .serviceError(404, _):
                    state.alert = AlertState(title: TextState("Схоже, логін або пароль невірний."))
                    analyticsClient.track(Event.Onboarding.campusUserLoadInvalidCredentials)
                    return .none

                case .serviceError,
                     .unknown:
                    state.alert = AlertState.error(error)
                    analyticsClient.track(Event.Onboarding.campusUserLoadFailed)
                    return .none
                }

            case let .lessonsResult(.failure(error)):
                state.isLoading = false
                state.alert = AlertState.error(error)
                analyticsClient.track(Event.Rozklad.lessonsLoadFailed(place: .campus))
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

}
