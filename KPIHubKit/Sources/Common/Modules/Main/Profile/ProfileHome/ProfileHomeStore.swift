//
//  ProfileHomeStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture
import Routes
import Foundation
import Services

@Reducer
public struct ProfileHome: Reducer {
    @ObservableState
    public struct State: Equatable {
        var rozkladState: RozkladServiceState.State = .notSelected
        var campusState: CampusServiceState.State = .loggedOut
        var lessonsUpdatedAtDate: Date?
        var completeAppVersion: String = ""
        
        @Presents var destination: Destination.State?
        var toggleWeek = false
        var isLoading = false
    }
    
    public enum Action: Equatable, ViewAction {
        case setRozkladState(RozkladServiceState.State)
        case setCampusState(CampusServiceState.State)
        case setLessonsUpdatedAtDate(Date?)
        
        case lessonsResult(TaskResult<[Lesson]>)
        
        case destination(PresentationAction<Destination.Action>)
        case view(View)
        case routeAction(RouteAction)

        public enum RouteAction: Equatable {
            case rozklad
            case campus
            case forDevelopers
        }
        
        public enum View: Equatable, BindableAction {
            case binding(BindingAction<State>)
            
            case updateRozkladButtonTapped
            case changeGroupButtonTapped
            case selectGroupButtonTapped
            
            case logoutCampusButtonTapped
            case loginCampusButtonTapped
            
            case forDevelopersButtonTapped
            
            case onAppear
        }
    }
        
    @Dependency(\.apiService) var apiClient
    @Dependency(\.userDefaultsService) var userDefaultsService
    @Dependency(\.rozkladServiceState) var rozkladServiceState
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    @Dependency(\.campusClientState) var campusClientState
    @Dependency(\.campusServiceStudySheet) var campusServiceStudySheet
    @Dependency(\.currentDateService) var currentDateService
    @Dependency(\.appConfiguration) var appConfiguration
    @Dependency(\.analyticsService) var analyticsService
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                state.completeAppVersion = appConfiguration.completeAppVersion ?? ""
                state.toggleWeek = userDefaultsService.get(for: .toggleWeek)
                analyticsService.track(Event.Profile.profileHomeAppeared)
                return onAppear(state: &state)

            case let .setRozkladState(rozkladState):
                state.rozkladState = rozkladState
                return .none

            case let .setCampusState(campusState):
                state.campusState = campusState
                return .none
                
            case let .setLessonsUpdatedAtDate(date):
                state.lessonsUpdatedAtDate = date
                return .none

            case .view(.updateRozkladButtonTapped):
                analyticsService.track(Event.Profile.reloadRozkladTapped)
                state.destination = .confirmationDialog(
                    ConfirmationDialogState(
                        title: TextState("Ви впевнені?"),
                        titleVisibility: .visible,
                        message: TextState("Оновлення розкладу видалить всі редагування!"),
                        buttons: [
                            .destructive(TextState("Оновити розклад"), action: .send(.confirmUpdateRozklad)),
                            .cancel(TextState("Назад"))
                        ]
                    )
                )
                return .none

            case let .lessonsResult(.success(lessons)):
                state.isLoading = false
                rozkladServiceLessons.set(.init(lessons, commitChanges: true))
                analyticsService.track(Event.Rozklad.lessonsLoadSuccess(place: .profileReload))
                return .none

            case let .lessonsResult(.failure(error)):
                state.isLoading = false
                state.destination = .alert(AlertState.error(error))
                analyticsService.track(Event.Rozklad.lessonsLoadFailed(place: .profileReload))
                return .none

            case .view(.changeGroupButtonTapped):
                analyticsService.track(Event.Profile.changeGroupTapped)
                state.destination = .confirmationDialog(
                    ConfirmationDialogState(
                        title: TextState("Ви впевнені?"),
                        titleVisibility: .visible,
                        message: TextState("Зміна групи видалить всі редагування!"),
                        buttons: [
                            .destructive(TextState("Змінити"), action: .send(.confirmChangeGroup)),
                            .cancel(TextState("Назад"))
                        ]
                    )
                )
                return .none
                
            case .view(.selectGroupButtonTapped):
                analyticsService.track(Event.Profile.selectGroup)
                return .send(.routeAction(.rozklad))

            case .view(.logoutCampusButtonTapped):
                analyticsService.track(Event.Profile.campusLogoutTapped)
                state.destination = .confirmationDialog(
                    ConfirmationDialogState(
                        title: TextState("Ви впевнені?"),
                        titleVisibility: .visible,
                        buttons: [
                            .destructive(TextState("Вийти"), action: .send(.confirmLogoutCampus)),
                            .cancel(TextState("Назад"))
                        ]
                    )
                )
                return .none

            case .view(.loginCampusButtonTapped):
                analyticsService.track(Event.Profile.campusLogin)
                return .send(.routeAction(.campus))

            case .view(.binding(\.toggleWeek)):
                userDefaultsService.set(state.toggleWeek, for: .toggleWeek)
                currentDateService.forceUpdate()
                analyticsService.track(Event.Profile.changeWeek(state.toggleWeek))
                return .none
                
            case .view(.forDevelopersButtonTapped):
                return .send(.routeAction(.forDevelopers))
                
            case .destination(.presented(.confirmationDialog(.confirmChangeGroup))):
                rozkladServiceState.setState(ClientValue(.notSelected, commitChanges: true))
                analyticsService.track(Event.Profile.changeGroup)
                analyticsService.setGroup(nil)
                return .send(.routeAction(.rozklad))
                
            case .destination(.presented(.confirmationDialog(.confirmLogoutCampus))):
                campusClientState.logout(ClientValue(commitChanges: true))
                campusServiceStudySheet.clean()
                analyticsService.track(Event.Profile.campusLogout)
                analyticsService.setCampusUser(nil)
                return .send(.routeAction(.campus))
                
            case .destination(.presented(.confirmationDialog(.confirmUpdateRozklad))):
                switch state.rozkladState {
                case let .selected(group):
                    state.isLoading = true
                    analyticsService.track(Event.Profile.reloadRozklad)
                    return .run { send in
                        let taskResult = await TaskResult {
                            let newGroup = try await apiClient.decodedResponse(
                                for: .api(.groups(.search(GroupSearchQuery(groupName: group.name)))),
                                as: GroupResponse.self
                            )
                            // Update lessons
                            let lessons = try await apiClient.decodedResponse(
                                for: .api(.group(newGroup.value.id, .lessons)),
                                as: LessonsResponse.self
                            )
                            rozkladServiceState.setState(ClientValue(.selected(newGroup.value), commitChanges: false))
                            return lessons.value.lessons.map { Lesson(lessonResponse: $0) }
                        }
                        await send(.lessonsResult(taskResult))
                    }

                case .notSelected:
                    return .none
                }
                
                
            case .destination(.dismiss):
                return .none

            case .view(.binding):
                return .none

            case .routeAction:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }
    
    private func onAppear(state: inout State) -> Effect<Action> {
        state.rozkladState = rozkladServiceState.currentState()
        state.lessonsUpdatedAtDate = rozkladServiceLessons.currentUpdatedAt()
        state.campusState = campusClientState.currentState()
        return .merge(
            .run { send in
                for await state in rozkladServiceState.stateStream().dropFirst() {
                    await send(.setRozkladState(state))
                }
            },
            .run { send in
                for await state in campusClientState.stateStream().dropFirst() {
                    await send(.setCampusState(state))
                }
            },
            .run { send in
                for await updatedAt in rozkladServiceLessons.updatedAtStream().dropFirst() {
                    await send(.setLessonsUpdatedAtDate(updatedAt))
                }
            }
        )
        .cancellable(id: CancelID.onAppear, cancelInFlight: true)
    }
    
    enum CancelID {
        case onAppear
    }
}

extension ProfileHome {
    @Reducer
    public struct Destination: Reducer {
        @ObservableState
        public enum State: Equatable {
            case alert(AlertState<Action.Alert>)
            case confirmationDialog(ConfirmationDialogState<Action.ConfirmationDialogAction>)
        }
        
        public enum Action: Equatable {
            case alert(Alert)
            case confirmationDialog(ConfirmationDialogAction)
            
            public enum Alert: Equatable { }
            
            public enum ConfirmationDialogAction {
                case confirmUpdateRozklad
                case confirmLogoutCampus
                case confirmChangeGroup
            }
        }
        
        public var body: some ReducerOf<Self> {
            EmptyReducer()
        }
    }
}
