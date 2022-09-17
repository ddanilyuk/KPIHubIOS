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

extension Campus.ScreenProvider {

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

    // MARK: - Reducer handling

    static let reducer = Reducer<State, Action, Campus.Environment>.combine(
        Reducer(
            Scope(state: /State.campusLogin, action: /Action.campusLogin) {
                CampusLogin()
            }
            
        ),
//        CampusLogin.reducer
//            .pullback(
//                state: /State.campusLogin,
//                action: /Action.campusLogin,
//                environment: {
//                    CampusLogin.Environment(
//                        apiClient: $0.apiClient,
//                        userDefaultsClient: $0.userDefaultsClient,
//                        campusClient: $0.campusClient,
//                        rozkladClient: $0.rozkladClient
//                    )
//                }
//            ),
        CampusHome.reducer
            .pullback(
                state: /State.campusHome,
                action: /Action.campusHome,
                environment: {
                    CampusHome.Environment(
                        apiClient: $0.apiClient,
                        userDefaultsClient: $0.userDefaultsClient,
                        campusClient: $0.campusClient
                    )
                }
            ),
        StudySheet.reducer
            .pullback(
                state: /State.studySheet,
                action: /Action.studySheet,
                environment: { _ in
                    StudySheet.Environment()
                }
            ),
        StudySheetItemDetail.reducer
            .pullback(
                state: /State.studySheetItemDetail,
                action: /Action.studySheetItemDetail,
                environment: { _ in
                    StudySheetItemDetail.Environment()
                }
            )
    )

}
