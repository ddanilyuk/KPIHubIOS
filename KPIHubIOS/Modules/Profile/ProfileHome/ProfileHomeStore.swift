//
//  ProfileHomeStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import ComposableArchitecture

struct ProfileHome {

    // MARK: - State

    struct State: Equatable {

        var updatedDate: Date?
        var rozkladState: RozkladClient.StateModule.State = .notSelected
        var campusState: CampusClient.StateModule.State = .loggedOut
//        var
        @BindableState var isLoading: Bool = false
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case onAppear

        case setUpdatedDate(Date?)
        case setRozkladState(RozkladClient.StateModule.State)
        case setCampusState(CampusClient.StateModule.State)

        case updateRozklad
        case lessonsResult(Result<[Lesson], NSError>)

        case changeGroup
        case selectGroup

        case campusLogout
        case campusLogin

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
        let userDefaultsClient: UserDefaultsClient
        let rozkladClient: RozkladClient
        let campusClient: CampusClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        enum SubscriberCancelId { }
        switch action {
        case .onAppear:
            return .merge(
                Effect.run { subscriber in
                    environment.rozkladClient.lessons.uploadedAt
                        .receive(on: DispatchQueue.main)
                        .sink { date in
                            subscriber.send(.setUpdatedDate(date))
                        }
                },
                Effect.run { subscriber in
                    environment.rozkladClient.state.subject
                        .receive(on: DispatchQueue.main)
                        .sink { rozkladState in
                            subscriber.send(.setRozkladState(rozkladState))
                        }
                },
                Effect.run { subscriber in
                    environment.campusClient.state.subject
                        .receive(on: DispatchQueue.main)
                        .sink { campusState in
                            subscriber.send(.setCampusState(campusState))
                        }
                }
            )
            .cancellable(id: SubscriberCancelId.self, cancelInFlight: true)

        case let .setUpdatedDate(date):
            state.updatedDate = date
            return .none

        case let .setRozkladState(rozkladState):
            state.rozkladState = rozkladState
            return .none

        case let .setCampusState(campusState):
            state.campusState = campusState
            return .none

        case .updateRozklad:
            switch state.rozkladState {
            case let .selected(group):
                state.isLoading = true
                let task: Effect<[Lesson], Error> = Effect.task {
                    let result = try await environment.apiClient.decodedResponse(
                        for: .api(.group(group.id, .lessons)),
                        as: LessonsResponse.self
                    )
                    environment.rozkladClient.state.select(group: group, commitChanges: false)
                    return result.value.lessons.map { Lesson(lessonResponse: $0) }
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
            environment.rozkladClient.lessons.set(lessons: lessons, commitChanges: true)
            return .none

        case let .lessonsResult(.failure(error)):
            state.isLoading = false
            return .none

        case .changeGroup:
            environment.rozkladClient.state.deselect(commitChanges: true)
            return Effect(value: .routeAction(.rozklad))

        case .selectGroup:
            return Effect(value: .routeAction(.rozklad))

        case .campusLogout:
            environment.campusClient.state.logOut(commitChanges: true)
            environment.campusClient.studySheet.removeLoaded()
            return Effect(value: .routeAction(.campus))

        case .campusLogin:
            return Effect(value: .routeAction(.campus))

        case .binding:
            return .none

        case .routeAction:
            return .none
        }
    }
    .binding()

}
