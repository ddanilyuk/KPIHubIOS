//
//  StudySheetItemDetailView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import SwiftUI
import ComposableArchitecture
import Services // TODO: ?

struct StudySheetItemDetailView: View {
    struct ViewState: Equatable {
        let itemName: String
        
        init(state: StudySheetItemDetail.State) {
            itemName = state.item.name
        }
    }
    
    private let store: StoreOf<StudySheetItemDetail>
    @ObservedObject private var viewStore: ViewStore<ViewState, StudySheetItemDetail.Action>
    
    init(store: StoreOf<StudySheetItemDetail>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init, send: { $0 })
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEachStore(
                    store.scope(state: \.cells, action: { .cells(id: $0, action: $1) }),
                    content: StudySheetActivityCellView.init(store:)
                )
            }
        }
        .navigationBarTitle(viewStore.itemName)
        .navigationBarTitleDisplayMode(.inline)
        // TODO: assets
//        .background(Color.screenBackground)
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
}

// MARK: - Preview
#Preview {
    StudySheetItemDetailView(
        store: Store(
            initialState: StudySheetItemDetail.State(
                item: StudySheetItem.mock1
            )
        ) {
            StudySheetItemDetail()
        }
    )
}
