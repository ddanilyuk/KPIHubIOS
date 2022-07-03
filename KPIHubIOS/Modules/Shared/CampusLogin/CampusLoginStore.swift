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

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClientable
        let campusClient: CampusClient
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
            state.focusedField = nil
            state.isLoading = true
            let task: Effect<CampusUserInfo, Error> = Effect.task {
                let result = try await environment.apiClient.request(
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
            environment.campusClient.state.login(
                ClientValue(
                    CampusClientState.LoginRequest(
                        credentials: campusCredentials,
                        userInfo: campusUserInfo
                    ),
                    commitChanges: false
                )
            )

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
                environment.rozkladClient.state.setState(ClientValue(.selected(group), commitChanges: false))
                return result.value.lessons.map { Lesson(lessonResponse: $0) }
            }
            return task
                .mapError { $0 as NSError }
                .receive(on: DispatchQueue.main)
                .catchToEffect(Action.lessonsResult)

        case let .lessonsResult(.success(lessons)):
            environment.rozkladClient.lessons.set(.init(lessons, commitChanges: true))
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

        case let .campusUserInfoResult(.failure(error)):
            state.isLoading = false
            switch error {
            case .serviceError(404, _):
                state.alert = AlertState(title: TextState("Схоже, логін або пароль невірний."))
                return .none

            case .serviceError,
                 .unknown:
                state.alert = AlertState.error(error)
                return .none
            }

        case let .lessonsResult(.failure(error)):
            state.isLoading = false
            state.alert = AlertState.error(error)
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
