//
//  CampusLoginStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 03.06.2022.
//

import ComposableArchitecture
import Routes

struct CampusLogin {

    // MARK: - State

    struct State: Equatable {

        // MARK: - Mode

        enum Mode {
            case onlyCampus
            case campusAndGroup
        }

        // MARK: - Properties

        @BindableState var username: String = ""
        @BindableState var password: String = ""
        @BindableState var isLoading: Bool = false

        var loginButtonEnabled: Bool = true

        let mode: Mode
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case login
        case campusUserInfoResult(Result<CampusUserInfo, NSError>)
        case groupSearchResult(Result<GroupResponse, APIError>)
        case lessonsResult(Result<[Lesson], NSError>)

        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction {
            case groupPicker
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
            state.isLoading = true
            let task: Effect<CampusUserInfo, Error> = Effect.task {
                let result = try await environment.apiClient.decodedResponse(
                    for: .api(.campus(.userInfo(campusLoginQuery))),
                    as: CampusUserInfo.self
                )
                return result.value
            }
            return task
                .mapError { $0 as NSError }
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.campusUserInfoResult)

        case let .campusUserInfoResult(.success(campusUserInfo)):

            let groupSearchQuery = GroupSearchQuery(
                groupName: campusUserInfo.studyGroup.name
            )

            /// Saving user info
            environment.userDefaultsClient.set(campusUserInfo, for: .campusUserInfo)

            /// Saving credentials after finding group
            let campusCredentials = CampusCredentials(
                username: state.username,
                password: state.password
            )
            environment.userDefaultsClient.set(campusCredentials, for: .campusCredentials)

            switch state.mode {
            case .onlyCampus:
                return Effect(value: .routeAction(.done))

            case .campusAndGroup:
                let task: Effect<GroupResponse, Error> = Effect.task {
                    let result = try await environment.apiClient.request(
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
            let task: Effect<[Lesson], Error> = Effect.task {
                let result = try await environment.apiClient.decodedResponse(
                    for: .api(.group(group.id, .lessons)),
                    as: LessonsResponse.self
                )
                environment.rozkladClient.set(group: group)
                return result.value.lessons.map { Lesson(lessonResponse: $0) }
            }
            return task
                .mapError { $0 as NSError }
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.lessonsResult)

        case let .lessonsResult(.success(lessons)):
            environment.rozkladClient.set(lessons: lessons)
            return Effect(value: .routeAction(.done))

        case let .groupSearchResult(.failure(error)):
            state.isLoading = false
            switch error {
            case .serviceError(404, _):
                return Effect(value: .routeAction(.groupPicker))

            case .serviceError,
                 .unknown:
                return .none
            }

        case let .campusUserInfoResult(.failure(error)),
             let .lessonsResult(.failure(error)):
            state.isLoading = false
            return .none

        case .binding:
            return .none

        case .routeAction:
            return .none
        }
    }
    .binding()

}
