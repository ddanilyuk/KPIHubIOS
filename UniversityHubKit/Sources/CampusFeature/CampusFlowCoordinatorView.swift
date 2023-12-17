//
//  CampusFlowCoordinatorView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

public struct CampusFlowCoordinatorView: View {
    private let store: StoreOf<Campus>

    public init(store: StoreOf<Campus>) {
        self.store = store
    }

    public var body: some View {
        Color.green
//        NavigationStackStore(
//            store.scope(state: \.path, action: Campus.Action.path),
//            root: {
//                IfLetStore(
//                    store.scope(state: \.campusRoot, action: Campus.Action.campusRoot)
//                ) { store in
//                    CampusRootView(store: store)
//                }
//            },
//            destination: { destination in
//                switch destination {
//                case .studySheet:
//                    CaseLet(
//                        /Campus.Path.State.studySheet,
//                        action: Campus.Path.Action.studySheet,
//                        then: StudySheetView.init
//                    )
//                    
//                case .studySheetItemDetail:
//                    CaseLet(
//                        /Campus.Path.State.studySheetItemDetail,
//                        action: Campus.Path.Action.studySheetItemDetail,
//                        then: StudySheetItemDetailView.init
//                    )
//                }
//            }
//        )
    }
}