//
//  CampusHome.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import Routes
import Foundation

struct CampusHome: ReducerProtocol {

    // MARK: - State

    struct State: Equatable {
        var openStudySheetOnLoad: Bool = false
        var studySheetState: CampusClientStudySheet.State = .notLoading

        @BindableState var isLoading: Bool = false
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case onAppear
        case refresh
        case studySheetTap
        case setStudySheetState(CampusClientStudySheet.State)

        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case studySheet([StudySheetItem])
        }
    }

    // MARK: - Environment
    
    @Dependency(\.campusClientStudySheet) var campusClientStudySheet
    @Dependency(\.analyticsClient) var analyticsClient

    // MARK: - Reducer
    
    enum SubscriberCancelIDTest { }
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                analyticsClient.track(Event.Campus.campusHomeAppeared)
                return Effect.run { subscriber in
                    campusClientStudySheet.subject
                        .receive(on: DispatchQueue.main)
                        .sink { state in
                            subscriber.send(.setStudySheetState(state))
                        }
                }
                .cancellable(id: SubscriberCancelIDTest.self, cancelInFlight: true)

            case .refresh:
                switch state.studySheetState {
                case .notLoading,
                     .loaded:
                    return campusClientStudySheet.load()
                        .fireAndForget()

                case .loading:
                    return .none
                }

            case let .setStudySheetState(studySheetState):
                state.studySheetState = studySheetState

                switch studySheetState {
                case .notLoading:
                    state.isLoading = false
                    // TODO: Add error state?
                    analyticsClient.track(Event.Campus.studySheetLoadFail)
                    return .none

                case .loading:
                    return .none

                case let .loaded(items):
                    state.isLoading = false
                    analyticsClient.track(
                        Event.Campus.studySheetLoadSuccess(itemsCount: items.count)
                    )
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
    }
    
}
