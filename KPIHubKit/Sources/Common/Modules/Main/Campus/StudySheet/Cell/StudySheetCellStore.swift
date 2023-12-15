//
//  StudySheetCellStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import Services

struct StudySheetCell: Reducer {
    struct State: Equatable, Identifiable {
        let item: StudySheetItem

        var id: StudySheetItem.ID {
            item.id
        }
    }
    
    enum Action: Equatable {
        case onTap
    }
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onTap:
                return .none
            }
        }
    }
}
