//
//  StudySheetItemDetail.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import IdentifiedCollections

struct StudySheetItemDetail: ReducerProtocol {

    // MARK: - State

    struct State: Equatable, Identifiable {

        let item: StudySheetItem
        var cells: IdentifiedArrayOf<StudySheetActivity.State>

        var id: StudySheetItem.ID {
            item.id
        }

        init(item: StudySheetItem) {
            self.item = item
            self.cells = IdentifiedArray(
                uniqueElements: item.activities.map(StudySheetActivity.State.init(activity:))
            )
        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case cells(id: StudySheetActivity.State.ID, action: StudySheetActivity.Action)
    }

    // MARK: - Reducer
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .cells:
                return .none
            }
        }
    }

}
