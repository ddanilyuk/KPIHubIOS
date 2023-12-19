//
//  CampusLoginStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 03.06.2022.
//

import ComposableArchitecture
import Routes
import Foundation
import Services
import RozkladModels
import RozkladServices

@Reducer
public struct CampusLoginFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public var focusedField: Field?
        public var username: String = ""
        public var password: String = ""
        public var isLoading = false
        @Presents public var alert: AlertState<Action.Alert>?
        
        public var loginButtonEnabled = false
        public let mode: Mode
        
        public init(mode: Mode) {
            self.mode = mode
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case local(Local)
        case alert(PresentationAction<Alert>)
        case route(Route)
        
        public enum Local {
            case campusUserInfoResult(Result<CampusUserInfo, Error>)
            case groupSearchResult(Result<GroupResponse, Error>)
            case lessonsResult(Result<[RozkladLessonModel], Error>)
        }
        
        public enum Route: Equatable {
            case groupPicker
            case done
        }
        
        public enum Alert: Equatable { }
        
        public enum View: BindableAction, Equatable {
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
    
    public init() { }
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)

        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
            case let .local(localAction):
                return handleLocalAction(state: &state, action: localAction)
                
            case .route:
                return .none
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
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
            
        case .binding(\.username):
            state.loginButtonEnabled = !state.username.isEmpty && !state.password.isEmpty
            return .none

        case .binding(\.password):
            state.loginButtonEnabled = !state.username.isEmpty && !state.password.isEmpty
            return .none
            
        case .binding:
            return .none
        }
    }
}

// MARK: Local
extension CampusLoginFeature {
    private func handleLocalAction(state: inout State, action: Action.Local) -> Effect<Action> {
        switch action {
        case let .groupSearchResult(.success(group)):
            analyticsService.setGroup(group)
            analyticsService.track(Event.Onboarding.campusUserGroupFound)
            return getLesson(for: group)
            
        case let .lessonsResult(.success(lessons)):
            // TODO:
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
            let campusUserInfo = await Result {
                // TODO: Move this request to service
                try await apiClient.request(
                    for: .api(.campus(.userInfo(campusLoginQuery))),
                    as: CampusUserInfo.self
                )
            }
            await send(.local(.campusUserInfoResult(campusUserInfo)))
        }
    }
    
    private func getGroups(campusUserInfo: CampusUserInfo) -> Effect<Action> {
        let groupSearchQuery = GroupSearchQuery(
            groupName: campusUserInfo.studyGroup.name
        )
        return .run { send in
            let resultTask = await Result {
                // TODO: Move this request to service
                try await apiClient.request(
                    for: .api(.groups(.search(groupSearchQuery))),
                    as: GroupResponse.self
                )
            }
            await send(.local(.groupSearchResult(resultTask)))
        }
    }
    
    private func getLesson(for group: GroupResponse) -> Effect<Action> {
        .run { send in
            let resultTask = await Result {
                try await rozkladServiceLessons.getLessons(groupID: group.id)
            }
            rozkladServiceState.setState(ClientValue(.selected(group), commitChanges: false))
            await send(.local(.lessonsResult(resultTask)))
        }
    }
}

// MARK: Helper models
extension CampusLoginFeature {
    public enum Mode {
        case onlyCampus
        case campusAndGroup
    }
    
    public enum Field: Hashable {
        case username
        case password
    }
}
