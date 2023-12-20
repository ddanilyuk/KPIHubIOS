//
//  StudySheetItemDetail.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import IdentifiedCollections
import Services
import CampusModels

struct StudySheetItemDetail: Reducer {
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
        case onAppear
        case cells(id: StudySheetActivity.State.ID, action: StudySheetActivity.Action)
    }

    // MARK: - Reducer
    
    @Dependency(\.analyticsService) var analyticsService
    
    var body: some ReducerOf<Self> {
        Reduce { _, action in
            switch action {
            case .onAppear:
                analyticsService.track(Event.Campus.studySheetItemDetailAppeared)
                return .none

            case .cells:
                return .none
            }
        }
    }
}
