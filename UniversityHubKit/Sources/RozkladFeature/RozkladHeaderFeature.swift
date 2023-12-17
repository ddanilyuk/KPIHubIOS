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
        public var currentLessonDay: LessonDay
        
        init(currentLessonDay: LessonDay?) {
            self.currentLessonDay = currentLessonDay ?? .init(day: 1, week: 1)
        }
    }
    
    public enum Action {
        case view(View)
        case output(Output)
        
        public enum Output {
            case selectWeek(Int)
            case selectDay(Int)
        }
        
        public enum View {
            case selectWeekButtonTapped(Int)
            case selectDayButtonTapped(Int)
        }
    }
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                return handleViewAction(state: &state, action: viewAction)
                
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
        case let .selectDayButtonTapped(day):
            guard state.currentLessonDay.day != day else {
                return .none
            }
            return .send(.output(.selectDay(day)), animation: .default)
            
        case let .selectWeekButtonTapped(week):
            guard state.currentLessonDay.week != week else {
                return .none
            }
            return .send(.output(.selectWeek(week)), animation: .default)
        }
    }
}
