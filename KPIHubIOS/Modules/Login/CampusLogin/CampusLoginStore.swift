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
        @BindableState var username: String = "dda77177"
        @BindableState var password: String = "4a78dd74"

        var loginButtonEnabled: Bool = true
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
            case loggedIn
        }
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClient
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
            /// Saving user info
            environment.userDefaultsClient.set(campusUserInfo, for: .campusUserInfo)

            /// Saving credentials
            let campusCredentials = CampusCredentials(
                username: state.username,
                password: state.password
            )
            environment.userDefaultsClient.set(campusCredentials, for: .campusCredentials)

            let groupSearchQuery = GroupSearchQuery(
                groupName: campusUserInfo.groupName
            )
            let task: Effect<GroupResponse, Error> = Effect.task {
                try await environment.apiClient.request(
                    for: .api(.groups(.search(groupSearchQuery))),
                    as: GroupResponse.self
                )
            }
            return task
                .mapError(APIError.init(error:))
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.groupSearchResult)

        case let .groupSearchResult(.success(group)):
            environment.userDefaultsClient.set(group, for: .group)
            let task: Effect<[Lesson], Error> = Effect.task {
                let result = try await environment.apiClient.decodedResponse(
                    for: .api(.group(group.id, .lessons)),
                    as: LessonsResponse.self
                )
                return result.value.lessons.map { Lesson(lessonResponse: $0) }
            }
            return task
                .mapError { $0 as NSError }
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.lessonsResult)

        case let .lessonsResult(.success(lessons)):
            environment.userDefaultsClient.set(lessons, for: .lessons)
            return Effect(value: .routeAction(.loggedIn))

        case let .groupSearchResult(.failure(error)):
            switch error {
            case .serviceError(404, _):
                return Effect(value: .routeAction(.groupPicker))

            case .serviceError,
                 .unknown:
                return .none
            }

        case let .campusUserInfoResult(.failure(error)),
             let .lessonsResult(.failure(error)):
            print(error)
            return .none

        case .binding:
            return .none

        case .routeAction:
            return .none
        }
    }
    .binding()


}
