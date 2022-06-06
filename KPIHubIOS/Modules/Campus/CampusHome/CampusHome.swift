//
//  CampusHome.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import Routes

struct CampusHome {

    // MARK: - State

    struct State: Equatable {

        @BindableState var isLoading: Bool = false

        var openSheet: Bool = false
        var studySheetState: CampusClient.StudySheetState = .notLoading

//        var studySheetItems: [StudySheetItem] = []
//        var studySheetLoadedState: LoadingState<[StudySheetItem]> = .notLoading

        enum LoadingState<T: Equatable>: Equatable {
            case notLoading
            case loading
            case loaded
            case openAfterLoading
        }
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case onAppear
        case studySheetTap
        case setStudySheetState(CampusClient.StudySheetState)
//        case studySheetResult(Result<[StudySheetItem], NSError>)

        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case studySheet([StudySheetItem])
        }
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClient
        let campusClient: CampusClient
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        switch action {
        case .onAppear:

            return Effect.run { subscriber in
                environment.campusClient.studySheetSubject
                    .sink { state in
                        subscriber.send(.setStudySheetState(state))
                    }
            }

//            guard state.studySheetLoadedState == .notLoading else {
//                return .none
//            }
//            guard let campusCredentials = environment.userDefaultsClient.get(for: .campusCredentials) else {
//                return .none
//            }
//            let campusLoginQuery = CampusLoginQuery(
//                username: campusCredentials.username,
//                password: campusCredentials.password
//            )
//            let task: Effect<[StudySheetItem], Error> = Effect.task {
//                let result = try await environment.apiClient.decodedResponse(
//                    for: .api(.campus(.studySheet(campusLoginQuery))),
//                    as: StudySheetResponse.self
//                )
//                return result.value.studySheet.map { StudySheetItem(studySheetItemResponse: $0) }
//            }
//            state.studySheetLoadedState = .loading
//            return task
//                .mapError { $0 as NSError }
//                .receive(on: DispatchQueue.main)
//                .catchToEffect(Action.studySheetResult)

        case let .setStudySheetState(studySheetState):
            state.studySheetState = studySheetState
            
            if case let .loaded(items) = studySheetState {
                if state.openSheet {
                    return Effect(value: .routeAction(
                        .studySheet(items)
                    ))
                } else {
                    return .none
                }

            } else {
                return .none
            }

        case .studySheetTap:
            switch state.studySheetState {
            case .notLoading:
                return .none

            case .loading:
                state.isLoading = true
                state.openSheet = true
                return .none

            case let .loaded(items):
                state.isLoading = false
                return Effect(value: .routeAction(
                    .studySheet(items)
                ))
            }

//            switch state.studySheetLoadedState {
//            case .loading:
//                state.isLoading = true
//                state.studySheetLoadedState = .openAfterLoading
//                return .none
//
//            case .loaded:
//                return Effect(value: .routeAction(
//                    .studySheet(state.studySheetItems)
//                ))
//
//            case .openAfterLoading, .notLoading:
//                return .none
//            }

//        case let .studySheetResult(.success(items)):
//            state.studySheetItems = items
//            state.isLoading = false
//            switch state.studySheetLoadedState {
//            case .openAfterLoading:
//                state.studySheetLoadedState = .loaded
//                return Effect(value: .routeAction(
//                    .studySheet(state.studySheetItems)
//                ))
//
//            case .loading,
//                 .notLoading,
//                 .loaded:
//                state.studySheetLoadedState = .loaded
//                return .none
//            }
//
//        case let .studySheetResult(.failure(error)):
//            return .none

        case .binding:
            return .none

        case .routeAction:
            return .none
        }
    }
    .binding()

}
