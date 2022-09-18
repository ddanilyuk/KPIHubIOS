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
    @ObservedObject var viewStore: ViewStoreOf<Rozklad>
    
    init(store: StoreOf<Rozklad>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }

    var body: some View {
        TCARouter(store) { screen in
            SwitchStore(screen) {
                CaseLet(
                    state: /Rozklad.ScreenProvider.State.groupPicker,
                    action: Rozklad.ScreenProvider.Action.groupPicker,
                    then: GroupPickerView.init
                )
                CaseLet(
                    state: /Rozklad.ScreenProvider.State.groupRozklad,
                    action: Rozklad.ScreenProvider.Action.groupRozklad,
                    then: GroupRozkladView.init
                )
                CaseLet(
                    state: /Rozklad.ScreenProvider.State.lessonDetails,
                    action: Rozklad.ScreenProvider.Action.lessonDetails,
                    then: LessonDetailsView.init
                )
                CaseLet(
                    state: /Rozklad.ScreenProvider.State.editLessonNames,
                    action: Rozklad.ScreenProvider.Action.editLessonNames,
                    then: EditLessonNamesView.init
                )
                CaseLet(
                    state: /Rozklad.ScreenProvider.State.editLessonTeachers,
                    action: Rozklad.ScreenProvider.Action.editLessonTeachers,
                    then: EditLessonTeachersView.init
                )
            }
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
    }

}
