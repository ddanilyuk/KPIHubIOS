//
//  RozkladView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

struct RozkladView: View {

    let store: Store<Rozklad.State, Rozklad.Action>

    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) {
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
            }
        }
    }

}
