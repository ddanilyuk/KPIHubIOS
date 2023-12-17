//
//  ProfileHomeRozkladFeature.swift
//  
//
//  Created by Denys Danyliuk on 17.12.2023.
//

import ComposableArchitecture
import RozkladModels
import RozkladServices
import Services
import Foundation

@Reducer
public struct ProfileHomeRozkladFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public var rozkladState: RozkladServiceState.State = .notSelected
        public var lessonsUpdatedAtDate: Date?
        public var toggleWeek = false
        @Presents public var destination: Destination.State?
        
        public init(
            rozkladState: RozkladServiceState.State,
            lessonsUpdatedAtDate: Date? = nil,
            toggleWeek: Bool = false
        ) {
            self.rozkladState = rozkladState
            self.lessonsUpdatedAtDate = lessonsUpdatedAtDate
            self.toggleWeek = toggleWeek
        }
    }
    
    public enum Action: Equatable, ViewAction {
        case view(View)
        case local(Local)
        case destination(PresentationAction<Destination.Action>)
        
        public enum View: Equatable, BindableAction {
            case binding(BindingAction<State>)
            case onAppear
            case updateRozkladButtonTapped
            case changeGroupButtonTapped
            case selectGroupButtonTapped
        }
        
        public enum Local: Equatable {
            case setRozkladState(RozkladServiceState.State)
            case setLessonsUpdatedAtDate(Date?)
        }
    }
    
    @Dependency(\.userDefaultsService) var userDefaultsService
    @Dependency(\.currentDateService) var currentDateService
    @Dependency(\.analyticsService) var analyticsService
    @Dependency(\.rozkladServiceState) var rozkladServiceState
    @Dependency(\.rozkladServiceLessons) var rozkladServiceLessons
    
    public init() { }

    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
            case let .local(localAction):
                return handleLocalAction(state: &state, action: localAction)
                
            case let .destination(destinationAction):
                return handleDestinationAction(state: &state, action: destinationAction)
            }
        }
        .ifLet(\.$destination, action: \.destination) {
            Destination()
        }
    }
    
    private func handleViewAction(state: inout State, action: Action.View) -> Effect<Action> {
        switch action {
        case .onAppear:
            return onAppear(state: &state)
            
        case .binding(\.toggleWeek):
            userDefaultsService.set(state.toggleWeek, for: .toggleWeek)
            currentDateService.forceUpdate()
            analyticsService.track(Event.Profile.changeWeek(state.toggleWeek))
            return .none
            
        case .changeGroupButtonTapped:
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
            
        case .selectGroupButtonTapped:
            analyticsService.track(Event.Profile.selectGroup)
            // TODO: .send(.routeAction(.rozklad))
            return .none
            
        case .updateRozkladButtonTapped:
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
            
        case .binding:
            return .none
        }
    }
    
    private func handleLocalAction(state: inout State, action: Action.Local) -> Effect<Action> {
        switch action {
        case let .setRozkladState(rozkladState):
            state.rozkladState = rozkladState
            return .none

        case let .setLessonsUpdatedAtDate(date):
            state.lessonsUpdatedAtDate = date
            return .none
        }
    }
    
    private func handleDestinationAction(
        state: inout State,
        action: PresentationAction<Destination.Action>
    ) -> Effect<Action> {
        switch action {
        case .presented:
            return .none
            
        case .dismiss:
            return .none
        }
    }
    
    private func onAppear(state: inout State) -> Effect<Action> {
        state.rozkladState = rozkladServiceState.currentState()
        state.lessonsUpdatedAtDate = rozkladServiceLessons.currentUpdatedAt()
        state.toggleWeek = userDefaultsService.get(for: .toggleWeek)
        return .merge(
            .run { send in
                for await state in rozkladServiceState.stateStream().dropFirst() {
                    await send(.local(.setRozkladState(state)))
                }
            },
            .run { send in
                for await updatedAt in rozkladServiceLessons.updatedAtStream().dropFirst() {
                    await send(.local(.setLessonsUpdatedAtDate(updatedAt)))
                }
            }
        )
        .cancellable(id: CancelID.onAppear, cancelInFlight: true)
    }
    
    private enum CancelID {
        case onAppear
    }
}

extension ProfileHomeRozkladFeature {
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
                case confirmChangeGroup
            }
        }
        
        public var body: some ReducerOf<Self> {
            EmptyReducer()
        }
    }
}
