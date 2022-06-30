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

        var openStudySheetOnLoad: Bool = false
        var studySheetState: CampusClientableStudySheet.State = .notLoading
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case onAppear
        case refresh
        case studySheetTap
        case setStudySheetState(CampusClientableStudySheet.State)

        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case studySheet([StudySheetItem])
        }
    }

    // MARK: - Environment

    struct Environment {
        let apiClient: APIClient
        let userDefaultsClient: UserDefaultsClientable
        let campusClient: CampusClientable
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, environment in
        enum SubscriberCancelIdTest { }
        switch action {
        case .onAppear:
            return Effect.run { subscriber in
                environment.campusClient.studySheet.subject
                    .receive(on: DispatchQueue.main)
                    .sink { state in
                        subscriber.send(.setStudySheetState(state))
                    }
            }
            .cancellable(id: SubscriberCancelIdTest.self, cancelInFlight: true)

        case .refresh:
            switch state.studySheetState {
            case .notLoading,
                 .loaded:
                return environment.campusClient.studySheet.load()
                    .fireAndForget()

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
                if state.openStudySheetOnLoad {
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
                state.openStudySheetOnLoad = true
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
