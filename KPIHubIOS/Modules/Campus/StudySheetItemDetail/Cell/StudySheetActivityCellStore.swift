//
//  StudySheetActivityCellStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture

struct StudySheetActivity {

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

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .onTap:
            return .none
        }
    }

}
