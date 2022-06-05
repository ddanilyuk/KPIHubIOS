//
//  CampusFlowCoordinatorView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct CampusFlowCoordinatorView: View {

    let store: Store<Campus.State, Campus.Action>

    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) {
                CaseLet(
                    state: /Campus.ScreenProvider.State.empty,
                    action: Campus.ScreenProvider.Action.empty,
                    then: EmptyScreenView.init
                )
                CaseLet(
                    state: /Campus.ScreenProvider.State.campusLogin,
                    action: Campus.ScreenProvider.Action.campusLogin,
                    then: CampusLoginView.init
                )
                CaseLet(
                    state: /Campus.ScreenProvider.State.campusHome,
                    action: Campus.ScreenProvider.Action.campusHome,
                    then: CampusHomeView.init
                )
                CaseLet(
                    state: /Campus.ScreenProvider.State.studySheet,
                    action: Campus.ScreenProvider.Action.studySheet,
                    then: StudySheetView.init
                )
                CaseLet(
                    state: /Campus.ScreenProvider.State.studySheetItemDetail,
                    action: Campus.ScreenProvider.Action.studySheetItemDetail,
                    then: StudySheetItemDetailView.init
                )
            }
        }
        .onAppear {
            ViewStore(store).send(.onAppear)
        }
    }

}
