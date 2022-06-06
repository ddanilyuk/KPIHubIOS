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
        case refresh
        case studySheetTap
        case setStudySheetState(CampusClient.StudySheetState)

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

        case .refresh:
            switch state.studySheetState {
            case .notLoading,
                 .loaded:
                environment.campusClient.startLoading()
                return .none

            case .loading:
                return .none
            }

        case let .setStudySheetState(studySheetState):
            state.studySheetState = studySheetState

            switch studySheetState {
            case .notLoading:
                state.isLoading = false
                return .none

            case .loading:
                return .none

            case let .loaded(items):
                state.isLoading = false
                if state.openSheet {
                    return Effect(value: .routeAction(
                        .studySheet(items)
                    ))
                } else {
                    return .none
                }
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

        case .binding:
            return .none

        case .routeAction:
            return .none
        }
    }
    .binding()

}
