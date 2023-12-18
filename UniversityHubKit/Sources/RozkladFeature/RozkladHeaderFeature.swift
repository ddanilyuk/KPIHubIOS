//
//  RozkladHeaderFeature.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import ComposableArchitecture
import RozkladModels

@Reducer
public struct RozkladHeaderFeature: Reducer {
    @ObservableState
    public struct State: Equatable {
        public var selectedLessonDay: LessonDay
        public var currentWeek: Int
        public var currentDay: Int?

        public init(selectedLessonDay: LessonDay?) {
            self.selectedLessonDay = selectedLessonDay ?? .init(day: 1, week: 1)
            
            @Dependency(\.currentDateService) var currentDateService
            self.currentWeek = currentDateService.currentWeek()
            self.currentDay = currentDateService.currentDay()
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case local(Local)
        case output(Output)
        
        public enum Output {
            case selectWeek(Int)
            case selectDay(Int)
        }
        
        public enum Local {
            case updateCurrentWeekAndDay
        }
        
        public enum View {
            case onTask
            case selectWeekButtonTapped(Int)
            case selectDayButtonTapped(Int)
        }
    }
    
    @Dependency(\.currentDateService) var currentDateService
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
            case let .local(localAction):
                return handleLocalAction(state: &state, action: localAction)
                
            case .output:
                return .none
            }
        }
    }
    
    private func handleViewAction(
        state: inout State,
        action: Action.View
    ) -> Effect<Action> {
        switch action {
        case .onTask:
            return .run { send in
                for await _ in currentDateService.updatedStream() {
                    await send(.local(.updateCurrentWeekAndDay))
                }
            }
            
        case let .selectDayButtonTapped(day):
            guard state.selectedLessonDay.day != day else {
                return .none
            }
            return .send(.output(.selectDay(day)), animation: .default)
            
        case let .selectWeekButtonTapped(week):
            guard state.selectedLessonDay.week != week else {
                return .none
            }
            return .send(.output(.selectWeek(week)), animation: .default)
        }
    }
    
    private func handleLocalAction(
        state: inout State,
        action: Action.Local
    ) -> Effect<Action> {
        switch action {
        case .updateCurrentWeekAndDay:
            state.currentWeek = currentDateService.currentWeek()
            state.currentDay = currentDateService.currentDay()
            return .none
        }
    }
}
