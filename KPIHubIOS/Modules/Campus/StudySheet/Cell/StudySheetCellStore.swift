//
//  StudySheetCellStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture

struct StudySheetCell {

    // MARK: - State

    struct State: Equatable, Identifiable {
        let item: StudySheetItem

        var id: StudySheetItem.ID {
            return item.id
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
