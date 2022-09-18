//
//  StudySheetItemDetailView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct StudySheetItemDetailView: View {

    let store: StoreOf<StudySheetItemDetail>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVStack {
                    ForEachStore(
                        self.store.scope(
                            state: \StudySheetItemDetail.State.cells,
                            action: StudySheetItemDetail.Action.cells(id:action:)
                        ),
                        content: StudySheetActivityCellView.init(store:)
                    )
                }
            }
            .navigationBarTitle("\(viewStore.item.name)")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.screenBackground)
        }
    }

}

// MARK: - Preview

struct StudySheetItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StudySheetItemDetailView(
                store: Store(
                    initialState: StudySheetItemDetail.State(
                        item: StudySheetItem.mock1
                    ),
                    reducer: StudySheetItemDetail()
                )
            )
        }
    }
}
