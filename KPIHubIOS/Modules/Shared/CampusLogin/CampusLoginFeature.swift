//
//  CampusLoginStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 03.06.2022.
//

import ComposableArchitecture
import Routes
import Foundation

struct CampusLoginFeature: Reducer {
    struct State: Equatable {
        @BindingState var focusedField: Field?
        @BindingState var username: String = ""
        @BindingState var password: String = ""
        @BindingState var isLoading = false
        @PresentationState var alert: AlertState<Action.Alert>?
        
        var loginButtonEnabled = false
        let mode: Mode
    }
    
    enum Action: Equatable {
        case view(View)
        case alert(PresentationAction<Alert>)
        case route(Route)
        
        case campusUserInfoResult(TaskResult<CampusUserInfo>)
        case groupSearchResult(TaskResult<GroupResponse>)
        case lessonsResult(TaskResult<[Lesson]>)
        
        enum Route: Equatable {
            case groupPicker
            case done
        }
        
        enum Alert: Equatable { }
        
        enum View: BindableAction, Equatable {
            case onAppear
            case loginButtonTapped
            case binding(BindingAction<State>)
        }
    }
    
    @Dependency(\.apiService) var apiClient
    @Dependency(\.campusClientState) var campusClientState
    @Dependency(\.rozkladServiceState) var rozkladServiceState
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    @Dependency(\.analyticsService) var analyticsService
    
    var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)

        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
            case let .campusUserInfoResult(.success(campusUserInfo)):
                /// Saving credentials after finding group
                let campusCredentials = CampusCredentials(
                    username: state.username,
                    password: state.password
                )
                campusClientState.login(
                    ClientValue(
                        CampusServiceState.LoginRequest(
                            credentials: campusCredentials,
                            userInfo: campusUserInfo
                        ),
                        commitChanges: false
                    )
                )
                analyticsService.setCampusUser(campusUserInfo)
                analyticsService.track(Event.Onboarding.campusUserLoadSuccess)

                switch state.mode {
                case .onlyCampus:
                    return .send(.route(.done))

                case .campusAndGroup:
                    return getGroups(campusUserInfo: campusUserInfo)
                }

            case let .groupSearchResult(.success(group)):
                analyticsService.setGroup(group)
                analyticsService.track(Event.Onboarding.campusUserGroupFound)
                return getLesson(for: group)
                
            case let .lessonsResult(.success(lessons)):
                rozkladServiceLessons.set(.init(lessons, commitChanges: true))
                analyticsService.track(Event.Rozklad.lessonsLoadSuccess(place: .campus))
                return .send(.route(.done))

            case let .groupSearchResult(.failure(error)):
                state.isLoading = false
                switch error as? APIError {
                case .serviceError(404, _):
                    analyticsService.track(Event.Onboarding.campusUserGroupNotFound)
                    return .send(.route(.groupPicker))

                case .serviceError, .unknown, .none:
                    analyticsService.track(Event.Onboarding.campusUserGroupFailed)
                    return .none
                }

            case let .campusUserInfoResult(.failure(error)):
                state.isLoading = false
                switch error as? APIError {
                case .serviceError(404, _):
                    state.alert = AlertState(title: TextState("Схоже, логін або пароль невірний."))
                    analyticsService.track(Event.Onboarding.campusUserLoadInvalidCredentials)
                    return .none

                case .serviceError, .unknown, .none:
                    state.alert = AlertState.error(error)
                    analyticsService.track(Event.Onboarding.campusUserLoadFailed)
                    return .none
                }

            case let .lessonsResult(.failure(error)):
                state.isLoading = false
                state.alert = AlertState.error(error)
                analyticsService.track(Event.Rozklad.lessonsLoadFailed(place: .campus))
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

// MARK: View
extension CampusLoginFeature {
    private func handleViewAction(state: inout State, action: Action.View) -> Effect<Action> {
        switch action {
        case .loginButtonTapped:
            state.focusedField = nil
            state.isLoading = true
            analyticsService.track(Event.Onboarding.campusLogin)
            return genCampusUserInfo(state: state)
            
        case .onAppear:
            analyticsService.track(Event.Onboarding.campusLoginAppeared)
            return .none
            
        case .binding(\.$username):
            state.loginButtonEnabled = !state.username.isEmpty && !state.password.isEmpty
            return .none

        case .binding(\.$password):
            state.loginButtonEnabled = !state.username.isEmpty && !state.password.isEmpty
            return .none
            
        case .binding:
            return .none
        }
    }
}

// MARK: API
extension CampusLoginFeature {
    private func genCampusUserInfo(state: State) -> Effect<Action> {
        let campusLoginQuery = CampusLoginQuery(
            username: state.username,
            password: state.password
        )
        return .run { send in
            let campusUserInfo = await TaskResult {
                try await apiClient.request(
                    for: .api(.campus(.userInfo(campusLoginQuery))),
                    as: CampusUserInfo.self
                )
            }
            await send(.campusUserInfoResult(campusUserInfo))
        }
    }
    
    private func getGroups(campusUserInfo: CampusUserInfo) -> Effect<Action> {
        let groupSearchQuery = GroupSearchQuery(
            groupName: campusUserInfo.studyGroup.name
        )
        return .run { send in
            let resultTask = await TaskResult {
                try await apiClient.request(
                    for: .api(.groups(.search(groupSearchQuery))),
                    as: GroupResponse.self
                )
            }
            await send(.groupSearchResult(resultTask))
        }
    }
    
    private func getLesson(for group: GroupResponse) -> Effect<Action> {
        .run { send in
            let resultTask = await TaskResult {
                try await apiClient.decodedResponse(
                    for: .api(.group(group.id, .lessons)),
                    as: LessonsResponse.self
                )
            }
            rozkladServiceState.setState(ClientValue(.selected(group), commitChanges: false))
            let lessons = resultTask.map { $0.value.lessons.map(Lesson.init) }
            await send(.lessonsResult(lessons))
        }
    }
}

// MARK: Helper models
extension CampusLoginFeature {
    enum Mode {
        case onlyCampus
        case campusAndGroup
    }
    
    enum Field: Hashable {
        case username
        case password
    }
}
