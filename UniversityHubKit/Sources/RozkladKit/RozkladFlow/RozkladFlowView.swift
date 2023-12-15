//
//  RozkladFlowView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

public struct RozkladFlowView: View {
    @Bindable public var store: StoreOf<RozkladFlow>
    
    public init(store: StoreOf<RozkladFlow>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path),
            root: {
                RozkladFlow.RozkladRootView(
                    store: store.scope(
                        state: \.rozkladRoot,
                        action: \.rozkladRoot
                    )
                )
            },
            destination: { store in
                switch store.withState({ $0 }) {
                case .lessonDetails:
                    if let store = store.scope(state: \.lessonDetails, action: \.lessonDetails) {
                        LessonDetailsView(store: store)
                    }
                }
            }
        )
    }
}
