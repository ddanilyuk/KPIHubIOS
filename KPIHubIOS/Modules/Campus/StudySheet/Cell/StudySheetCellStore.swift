//
//  StudySheetCellStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture

struct StudySheetCell: Reducer {

    // MARK: - State

    struct State: Equatable, Identifiable {
        let item: StudySheetItem

        var id: StudySheetItem.ID {
            item.id
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case onTap
    }

    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onTap:
                return .none
            }
        }
    }

}
