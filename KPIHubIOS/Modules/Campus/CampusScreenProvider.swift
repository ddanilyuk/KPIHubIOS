//
//  CampusScreenProvider.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture

extension Campus {

    struct ScreenProvider {}

}

extension Campus.ScreenProvider: Reducer {

    // MARK: - State handling

    enum State: Equatable, CoordinatorStateIdentifiable {

        static var module: Any.Type = Campus.self

        case campusLogin(CampusLogin.State)
        case campusHome(CampusHome.State)
        case studySheet(StudySheet.State)
        case studySheetItemDetail(StudySheetItemDetail.State)
    }

    // MARK: - Action handling

    enum Action: Equatable {

        case campusLogin(CampusLogin.Action)
        case campusHome(CampusHome.Action)
        case studySheet(StudySheet.Action)
        case studySheetItemDetail(StudySheetItemDetail.Action)
    }

    // MARK: - Reducer
    
    var body: some ReducerOf<Self> {
        Scope(state: /State.campusLogin, action: /Action.campusLogin) {
            CampusLogin()
        }
        Scope(state: /State.campusHome, action: /Action.campusHome) {
            CampusHome()
        }
        Scope(state: /State.studySheet, action: /Action.studySheet) {
            StudySheet()
        }
        Scope(state: /State.studySheetItemDetail, action: /Action.studySheetItemDetail) {
            StudySheetItemDetail()
        }
    }

}
