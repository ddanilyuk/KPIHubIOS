//
//  CampusScreenProvider.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture

extension Campus {
    struct Path {}
}

extension Campus.Path: Reducer {
    enum State: Equatable {
        case studySheet(StudySheet.State)
        case studySheetItemDetail(StudySheetItemDetail.State)
    }
    
    enum Action: Equatable {
        case studySheet(StudySheet.Action)
        case studySheetItemDetail(StudySheetItemDetail.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.studySheet, action: /Action.studySheet) {
            StudySheet()
        }
        Scope(state: /State.studySheetItemDetail, action: /Action.studySheetItemDetail) {
            StudySheetItemDetail()
        }
    }
}
