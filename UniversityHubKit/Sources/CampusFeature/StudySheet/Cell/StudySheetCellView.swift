//
//  StudySheetCellView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import SwiftUI
import ComposableArchitecture
import DesignKit
import Services // TODO: ?
import CampusModels
import CampusServices

struct StudySheetCellView: View {
    struct ViewState: Equatable {
        let item: StudySheetItem
        
        init(state: StudySheetCell.State) {
            item = state.item
        }
    }
    
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject private var viewStore: ViewStore<ViewState, StudySheetCell.Action>
    
    init(store: StoreOf<StudySheetCell>) {
        viewStore = ViewStore(store, observe: { ViewState(state: $0) })
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(colorScheme == .light ? Color.white : Color(.tertiarySystemFill))
                .if(colorScheme == .light) { view in
                    view
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                }

            VStack(alignment: .leading, spacing: 10) {
                Text(viewStore.item.name)
                    .font(.system(.headline).bold())
                    .lineLimit(2)

                ForEach(viewStore.item.teachers, id: \.self) { teacher in
                    SmallTagView(
                        icon: Image(systemName: "person"),
                        text: teacher,
                        color: .indigo
                    )
                }

                HStack(spacing: 16) {
                    SmallTagView(
                        icon: Image(systemName: "calendar"),
                        text: "\(viewStore.item.year)",
                        color: .yellow
                    )

                    SmallTagView(
                        icon: Image(systemName: "calendar"),
                        text: "\(viewStore.item.semester) семетр",
                        color: .yellow
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .onTapGesture {
            viewStore.send(.onTap)
        }
    }
}

// MARK: - Preview
#Preview {
    StudySheetCellView(
        store: Store(initialState: StudySheetCell.State(item: StudySheetItem.mock1)) {
            StudySheetCell()
        }
    )
    .smallPreview
    .padding(16)
    // TODO: assets
//    .background(Color.screenBackground)
}
