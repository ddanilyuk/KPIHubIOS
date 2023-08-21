//
//  RozkladFlowCoordinatorView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators
import FirebaseCore
import FirebaseAnalytics

struct RozkladFlowCoordinatorView: View {

    let store: StoreOf<Rozklad>

    var body: some View {
        NavigationStackStore(
            store.scope(state: \.path, action: Rozklad.Action.path),
            root: {
                RozkladRootView(
                    store: store.scope(
                        state: \.rozkladRoot,
                        action: Rozklad.Action.rozkladRoot
                    )
                )
            },
            destination: { destination in
                switch destination {
                case .lessonDetails:
                    CaseLet(
                        /Rozklad.Path.State.lessonDetails,
                        action: Rozklad.Path.Action.lessonDetails,
                        then: LessonDetailsView.init
                    )
                case .editLessonNames:
                    CaseLet(
                        /Rozklad.Path.State.editLessonNames,
                        action: Rozklad.Path.Action.editLessonNames,
                        then: EditLessonNamesView.init
                    )
                case .editLessonTeachers:
                    CaseLet(
                        /Rozklad.Path.State.editLessonTeachers,
                        action: Rozklad.Path.Action.editLessonTeachers,
                        then: EditLessonTeachersView.init
                    )
                }
            }
        )
    }

}
