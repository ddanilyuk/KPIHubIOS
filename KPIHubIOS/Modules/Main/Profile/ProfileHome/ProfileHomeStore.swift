//
//  ProfileHomeStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture
import Routes
import Foundation

struct ProfileHome: Reducer {

    // MARK: - State

    struct State: Equatable {

        var rozkladState: RozkladServiceState.State = .notSelected
        var campusState: CampusServiceState.State = .loggedOut
        var lessonsUpdatedAtDate: Date?
        @BindingState var toggleWeek: Bool = false
        var completeAppVersion: String = ""

        var confirmationDialog: ConfirmationDialogState<Action>?
        var alert: AlertState<Action>?
        @BindingState var isLoading: Bool = false
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case onAppear

        case setRozkladState(RozkladServiceState.State)
        case setCampusState(CampusServiceState.State)
        case setLessonsUpdatedAtDate(Date?)

        case updateRozkladButtonTapped
        case updateRozklad
        case lessonsResult(Result<[Lesson], NSError>)

        case changeGroupButtonTapped
        case changeGroup
        case selectGroup

        case logoutCampusButtonTapped
        case logoutCampus
        case loginCampus

        case dismissConfirmationDialog
        case dismissAlert
        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case rozklad
            case campus
            case forDevelopers
        }
    }

    // MARK: - Environment
    
    @Dependency(\.apiService) var apiClient
    @Dependency(\.userDefaultsService) var userDefaultsService
    @Dependency(\.rozkladServiceState) var rozkladServiceState
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    @Dependency(\.campusClientState) var campusClientState
    @Dependency(\.campusServiceStudySheet) var campusServiceStudySheet
    @Dependency(\.currentDateClient) var currentDateClient
    @Dependency(\.appConfiguration) var appConfiguration
    @Dependency(\.analyticsService) var analyticsService

    // MARK: - Reducer
    
    enum SubscriberCancelID { }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.completeAppVersion = appConfiguration.completeAppVersion ?? ""
                state.toggleWeek = userDefaultsService.get(for: .toggleWeek)
                analyticsService.track(Event.Profile.profileHomeAppeared)
                return onAppear()

            case let .setRozkladState(rozkladState):
                state.rozkladState = rozkladState
                return .none

            case let .setCampusState(campusState):
                state.campusState = campusState
                return .none
                
            case let .setLessonsUpdatedAtDate(date):
                state.lessonsUpdatedAtDate = date
                return .none

            case .updateRozkladButtonTapped:
                analyticsService.track(Event.Profile.reloadRozkladTapped)
                state.confirmationDialog = ConfirmationDialogState(
                    title: TextState("Ви впевнені?"),
                    titleVisibility: .visible,
                    message: TextState("Оновлення розкладу видалить всі редагування!"),
                    buttons: [
                        .destructive(TextState("Оновити розклад"), action: .send(.updateRozklad)),
                        .cancel(TextState("Назад"))
                    ]
                )
                return .none

            case .updateRozklad:
                switch state.rozkladState {
                case let .selected(group):
                    state.isLoading = true
                    analyticsService.track(Event.Profile.reloadRozklad)
                    let task: EffectPublisher<[Lesson], Error> = EffectPublisher.task {
                        // Update group id using name
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
                    return task
                        .mapError { $0 as NSError }
                        .receive(on: DispatchQueue.main)
                        .catchToEffect(Action.lessonsResult)

                case .notSelected:
                    return .none
                }

            case let .lessonsResult(.success(lessons)):
                state.isLoading = false
                rozkladServiceLessons.set(.init(lessons, commitChanges: true))
                analyticsService.track(Event.Rozklad.lessonsLoadSuccess(place: .profileReload))
                return .none

            case let .lessonsResult(.failure(error)):
                state.isLoading = false
                state.alert = AlertState.error(error)
                analyticsService.track(Event.Rozklad.lessonsLoadFailed(place: .profileReload))
                return .none

            case .changeGroupButtonTapped:
                analyticsService.track(Event.Profile.changeGroupTapped)
                state.confirmationDialog = ConfirmationDialogState(
                    title: TextState("Ви впевнені?"),
                    titleVisibility: .visible,
                    message: TextState("Зміна групи видалить всі редагування!"),
                    buttons: [
                        .destructive(TextState("Змінити"), action: .send(.changeGroup)),
                        .cancel(TextState("Назад"))
                    ]
                )
                return .none

            case .changeGroup:
                rozkladServiceState.setState(ClientValue(.notSelected, commitChanges: true))
                analyticsService.track(Event.Profile.changeGroup)
                analyticsService.setGroup(nil)
                return Effect(value: .routeAction(.rozklad))

            case .selectGroup:
                analyticsService.track(Event.Profile.selectGroup)
                return Effect(value: .routeAction(.rozklad))

            case .logoutCampusButtonTapped:
                analyticsService.track(Event.Profile.campusLogoutTapped)
                state.confirmationDialog = ConfirmationDialogState(
                    title: TextState("Ви впевнені?"),
                    titleVisibility: .visible,
                    buttons: [
                        .destructive(TextState("Вийти"), action: .send(.logoutCampus)),
                        .cancel(TextState("Назад"))
                    ]
                )
                return .none

            case .logoutCampus:
                campusClientState.logout(ClientValue(commitChanges: true))
                campusServiceStudySheet.clean()
                analyticsService.track(Event.Profile.campusLogout)
                analyticsService.setCampusUser(nil)
                return Effect(value: .routeAction(.campus))

            case .loginCampus:
                analyticsService.track(Event.Profile.campusLogin)
                return Effect(value: .routeAction(.campus))

            case .binding(\.rozkladSectionView.$toggleWeek):
                userDefaultsService.set(state.toggleWeek, for: .toggleWeek)
                currentDateClient.forceUpdate()
                analyticsService.track(Event.Profile.changeWeek(state.toggleWeek))
                return .none

            case .dismissConfirmationDialog:
                state.confirmationDialog = nil
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
    
    private func onAppear() -> Effect<Action> {
        return .merge(
            Effect(value: .setRozkladState(rozkladServiceState.subject.value)),
            Effect(value: .setCampusState(campusClientState.subject.value)),
            Effect(value: .setLessonsUpdatedAtDate(rozkladServiceLessons.updatedAtSubject.value)),
            Effect.run { subscriber in
                rozkladServiceState.subject
                    .dropFirst()
                    .receive(on: DispatchQueue.main)
                    .sink { rozkladState in
                        subscriber.send(.setRozkladState(rozkladState))
                    }
            },
            Effect.run { subscriber in
                campusClientState.subject
                    .dropFirst()
                    .receive(on: DispatchQueue.main)
                    .sink { campusState in
                        subscriber.send(.setCampusState(campusState))
                    }
            },
            Effect.run { subscriber in
                rozkladServiceLessons.updatedAtSubject
                    .dropFirst()
                    .receive(on: DispatchQueue.main)
                    .sink { date in
                        subscriber.send(.setLessonsUpdatedAtDate(date))
                    }
            }
        )
        .cancellable(id: SubscriberCancelID.self, cancelInFlight: true)
    }
    
}
