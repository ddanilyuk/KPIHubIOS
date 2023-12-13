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
            store.scope(state: \.path, action: { .path($0) }),
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
                }
            }
        )
    }
}
