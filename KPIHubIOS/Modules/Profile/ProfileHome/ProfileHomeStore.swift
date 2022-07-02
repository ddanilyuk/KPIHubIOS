//
//  ProfileHomeStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture
import Routes

struct ProfileHome {

    // MARK: - State

    struct State: Equatable {

        var rozkladState: RozkladClientState.State = .notSelected
        var campusState: CampusClientableState.State = .loggedOut
        var lessonsUpdatedAtDate: Date?
        @BindableState var toggleWeek: Bool = false

        var confirmationDialog: ConfirmationDialogState<Action>?
        var alert: AlertState<Action>?
        @BindableState var isLoading: Bool = false
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case onAppear

        case setRozkladState(RozkladClientState.State)
        case setCampusState(CampusClientableState.State)
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

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClientable
        let rozkladClient: RozkladClient
        let campusClient: CampusClientable
        let currentDateClient: CurrentDateClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        enum SubscriberCancelId { }
        switch action {
        case .onAppear:
            state.toggleWeek = environment.userDefaultsClient.get(for: .toggleWeek)
            return Effect.setAndSubscribeOnAppear(
                environment: environment,
                cancellable: SubscriberCancelId.self
            )

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
                let task: Effect<[Lesson], Error> = Effect.task {
                    // Update group id using name
                    let newGroup = try await environment.apiClient.decodedResponse(
                        for: .api(.groups(.search(GroupSearchQuery(groupName: group.name)))),
                        as: GroupResponse.self
                    )
                    // Update lessons
                    let lessons = try await environment.apiClient.decodedResponse(
                        for: .api(.group(newGroup.value.id, .lessons)),
                        as: LessonsResponse.self
                    )
                    environment.rozkladClient.state.setState(ClientValue(.selected(newGroup.value), commitChanges: false))
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
            environment.rozkladClient.lessons.set(.init(lessons, commitChanges: true))
            return .none

        case let .lessonsResult(.failure(error)):
            state.isLoading = false
            state.alert = AlertState.error(error)
            return .none

        case .changeGroupButtonTapped:
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
            environment.rozkladClient.state.setState(ClientValue(.notSelected, commitChanges: true))
            return Effect(value: .routeAction(.rozklad))

        case .selectGroup:
            return Effect(value: .routeAction(.rozklad))

        case .logoutCampusButtonTapped:
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
            environment.campusClient.state.logout(ClientValue(commitChanges: true))
            environment.campusClient.studySheet.clean()
            return Effect(value: .routeAction(.campus))

        case .loginCampus:
            return Effect(value: .routeAction(.campus))

        case .binding(\.rozkladSectionView.$toggleWeek):
            environment.userDefaultsClient.set(state.toggleWeek, for: .toggleWeek)
            environment.currentDateClient.forceUpdate()
            return .none

        case .dismissConfirmationDialog:
            state.confirmationDialog = nil
            return .none

        case .dismissAlert:
            state.alert = nil
            return .none

        case let .binding(action):
            return .none

        case .routeAction:
            return .none
        }
    }
    .binding()

}

extension Effect where Output == ProfileHome.Action, Failure == Never {

    static func setAndSubscribeOnAppear(environment: ProfileHome.Environment, cancellable: Any.Type) -> Self {
        return .merge(
            Effect(value: .setRozkladState(environment.rozkladClient.state.subject.value)),
            Effect(value: .setCampusState(environment.campusClient.state.subject.value)),
            Effect(value: .setLessonsUpdatedAtDate(environment.rozkladClient.lessons.updatedAtSubject.value)),
            Effect.run { subscriber in
                environment.rozkladClient.state.subject
                    .dropFirst()
                    .receive(on: DispatchQueue.main)
                    .sink { rozkladState in
                        subscriber.send(.setRozkladState(rozkladState))
                    }
            },
            Effect.run { subscriber in
                environment.campusClient.state.subject
                    .dropFirst()
                    .receive(on: DispatchQueue.main)
                    .sink { campusState in
                        subscriber.send(.setCampusState(campusState))
                    }
            },
            Effect.run { subscriber in
                environment.rozkladClient.lessons.updatedAtSubject
                    .dropFirst()
                    .receive(on: DispatchQueue.main)
                    .sink { date in
                        subscriber.send(.setLessonsUpdatedAtDate(date))
                    }
            }
        )
        .cancellable(id: cancellable, cancelInFlight: true)
    }
}
