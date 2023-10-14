//
//  RozkladFlowView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct RozkladFlowView: View {
    private let store: StoreOf<RozkladFlow>
    
    init(store: StoreOf<RozkladFlow>) {
        self.store = store
    }
    
    var body: some View {
        NavigationStackStore(
            store.scope(state: \.path, action: RozkladFlow.Action.path),
            root: {
                RozkladFlow.RozkladRootView(
                    store: store.scope(
                        state: \.rozkladRoot,
                        action: RozkladFlow.Action.rozkladRoot
                    )
                )
            },
            destination: { destination in
                switch destination {
                case .lessonDetails:
                    CaseLet(
                        /RozkladFlow.Path.State.lessonDetails,
                        action: RozkladFlow.Path.Action.lessonDetails,
                        then: LessonDetailsView.init
                    )
//                case .editLessonNames:
//                    CaseLet(
//                        /RozkladFlow.Path.State.editLessonNames,
//                        action: RozkladFlow.Path.Action.editLessonNames,
//                        then: EditLessonNamesView.init
//                    )
//                case .editLessonTeachers:
//                    CaseLet(
//                        /RozkladFlow.Path.State.editLessonTeachers,
//                        action: RozkladFlow.Path.Action.editLessonTeachers,
//                        then: EditLessonTeachersView.init
//                    )
                }
            }
        )
    }
}
