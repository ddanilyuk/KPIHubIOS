//
//  StudySheetActivityCellStore.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import GeneralServices
import CampusModels

struct StudySheetActivity: Reducer {
    struct State: Equatable, Identifiable {
        let activity: StudySheetItem.Activity

        var id: StudySheetItem.Activity.ID {
            activity.id
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
