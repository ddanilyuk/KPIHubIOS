//
//  StudySheetActivityCellStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture

struct StudySheetActivity: ReducerProtocol {

    // MARK: - State

    struct State: Equatable, Identifiable {
        var activity: StudySheetItem.Activity

        var id: StudySheetItem.Activity.ID {
            activity.id
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onTap
    }

    // MARK: - Reducer
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onTap:
                return .none
            }
        }
    }

}
