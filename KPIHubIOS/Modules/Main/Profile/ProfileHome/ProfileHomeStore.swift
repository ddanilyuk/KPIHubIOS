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

        var rozkladState: RozkladClientState.State = .notSelected
        var campusState: CampusClientState.State = .loggedOut
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

        case setRozkladState(RozkladClientState.State)
        case setCampusState(CampusClientState.State)
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
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    @Dependency(\.rozkladClientState) var rozkladClientState
    @Dependency(\.rozkladClientLessons) var rozkladClientLessons
    @Dependency(\.campusClientState) var campusClientState
    @Dependency(\.campusClientStudySheet) var campusClientStudySheet
    @Dependency(\.currentDateClient) var currentDateClient
    @Dependency(\.appConfiguration) var appConfiguration
    @Dependency(\.analyticsClient) var analyticsClient

    // MARK: - Reducer
    
    enum SubscriberCancelID { }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.completeAppVersion = appConfiguration.completeAppVersion ?? ""
                state.toggleWeek = userDefaultsClient.get(for: .toggleWeek)
                analyticsClient.track(Event.Profile.profileHomeAppeared)
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
                analyticsClient.track(Event.Profile.reloadRozkladTapped)
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
                    analyticsClient.track(Event.Profile.reloadRozklad)
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
                        rozkladClientState.setState(ClientValue(.selected(newGroup.value), commitChanges: false))
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
                rozkladClientLessons.set(.init(lessons, commitChanges: true))
                analyticsClient.track(Event.Rozklad.lessonsLoadSuccess(place: .profileReload))
                return .none

            case let .lessonsResult(.failure(error)):
                state.isLoading = false
                state.alert = AlertState.error(error)
                analyticsClient.track(Event.Rozklad.lessonsLoadFailed(place: .profileReload))
                return .none

            case .changeGroupButtonTapped:
                analyticsClient.track(Event.Profile.changeGroupTapped)
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
                rozkladClientState.setState(ClientValue(.notSelected, commitChanges: true))
                analyticsClient.track(Event.Profile.changeGroup)
                analyticsClient.setGroup(nil)
                return Effect(value: .routeAction(.rozklad))

            case .selectGroup:
                analyticsClient.track(Event.Profile.selectGroup)
                return Effect(value: .routeAction(.rozklad))

            case .logoutCampusButtonTapped:
                analyticsClient.track(Event.Profile.campusLogoutTapped)
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
                campusClientStudySheet.clean()
                analyticsClient.track(Event.Profile.campusLogout)
                analyticsClient.setCampusUser(nil)
                return Effect(value: .routeAction(.campus))

            case .loginCampus:
                analyticsClient.track(Event.Profile.campusLogin)
                return Effect(value: .routeAction(.campus))

            case .binding(\.rozkladSectionView.$toggleWeek):
                userDefaultsClient.set(state.toggleWeek, for: .toggleWeek)
                currentDateClient.forceUpdate()
                analyticsClient.track(Event.Profile.changeWeek(state.toggleWeek))
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
            Effect(value: .setRozkladState(rozkladClientState.subject.value)),
            Effect(value: .setCampusState(campusClientState.subject.value)),
            Effect(value: .setLessonsUpdatedAtDate(rozkladClientLessons.updatedAtSubject.value)),
            Effect.run { subscriber in
                rozkladClientState.subject
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
                rozkladClientLessons.updatedAtSubject
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
