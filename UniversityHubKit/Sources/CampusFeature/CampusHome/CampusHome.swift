//
//  CampusHome.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import Routes
import Foundation
import ConcurrencyExtras
import GeneralServices
import CampusModels
import CampusServices

@Reducer
public struct CampusHome: Reducer {
    public struct State: Equatable {
        var openStudySheetOnLoad = false
        var studySheetState: CampusServiceStudySheet.State = .notLoading

        @BindingState var isLoading = false
    }

    public enum Action: Equatable {
        case setStudySheetState(CampusServiceStudySheet.State)
        
        case view(View)
        case routeAction(RouteAction)

        public enum RouteAction: Equatable {
            case studySheet([StudySheetItem])
        }
        
        public enum View: Equatable, BindableAction {
            case onAppear
            case refresh
            case studySheetTap
            case binding(BindingAction<State>)
        }
    }
    
    @Dependency(\.campusServiceStudySheet) var campusServiceStudySheet
    @Dependency(\.analyticsService) var analyticsService

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(viewAction, state: &state)

            case let .setStudySheetState(studySheetState):
                state.studySheetState = studySheetState

                switch studySheetState {
                case .notLoading:
                    state.isLoading = false
                    analyticsService.track(Event.Campus.studySheetLoadFail)
                    return .none

                case .loading:
                    return .none

                case let .loaded(items):
                    state.isLoading = false
                    analyticsService.track(
                        Event.Campus.studySheetLoadSuccess(itemsCount: items.count)
                    )
                    if state.openStudySheetOnLoad {
                        return .send(.routeAction(.studySheet(items)))
                    } else {
                        return .none
                    }
                }

            case .routeAction:
                return .none
            }
        }
    }
    
    private func handleViewAction(_ action: Action.View, state: inout State) -> Effect<Action> {
        switch action {
        case .onAppear:
            analyticsService.track(Event.Campus.campusHomeAppeared)
            return .run { send in
                for await state in campusServiceStudySheet.stateStream() {
                    await send(.setStudySheetState(state))
                }
            }
            .cancellable(id: CancelID.campusService, cancelInFlight: true)

        case .refresh:
            switch state.studySheetState {
            case .notLoading, .loaded:
                return .run { _ in
                    await campusServiceStudySheet.load()
                }

            case .loading:
                return .none
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
                return .send(.routeAction(.studySheet(items)))
            }

        case .binding:
            return .none
        }
    }
    
    private enum CancelID {
        case campusService
    }
}
