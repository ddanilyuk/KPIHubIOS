//
//  RozkladFlowCoordinatorView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct RozkladFlowCoordinatorView: View {

    let store: Store<Rozklad.State, Rozklad.Action>

    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) {
                CaseLet(
                    state: /Rozklad.ScreenProvider.State.empty,
                    action: Rozklad.ScreenProvider.Action.empty,
                    then: EmptyScreenView.init
                )
                CaseLet(
                    state: /Rozklad.ScreenProvider.State.groupLessons,
                    action: Rozklad.ScreenProvider.Action.groupLessons,
                    then: GroupLessonsView.init
                )
                CaseLet(
                    state: /Rozklad.ScreenProvider.State.lessonDetails,
                    action: Rozklad.ScreenProvider.Action.lessonDetails,
                    then: LessonDetailsView.init
                )
                CaseLet(
                    state: /Rozklad.ScreenProvider.State.groupPicker,
                    action: Rozklad.ScreenProvider.Action.groupPicker,
                    then: GroupPickerView.init
                )
            }
        }
    }

}
