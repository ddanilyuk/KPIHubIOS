//
//  StudySheetCellView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct StudySheetCellView: View {

    let store: Store<StudySheetCell.State, StudySheetCell.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                VStack(alignment: .leading, spacing: 10) {
                    Text(viewStore.item.name)
                        .font(.system(.headline).bold())
                        .lineLimit(2)

                    ForEach(viewStore.item.teachers, id: \.self) { teacher in
                        SmallTagView(
                            icon: Image(systemName: "person"),
                            text: teacher,
                            backgroundColor: Color.indigo.lighter(by: 0.9),
                            accentColor: Color.indigo
                        )
                    }

                    HStack(spacing: 16) {
                        SmallTagView(
                            icon: Image(systemName: "calendar"),
                            text: "\(viewStore.item.year)",
                            backgroundColor: Color.yellow.lighter(by: 0.9),
                            accentColor: Color.yellow
                        )

                        SmallTagView(
                            icon: Image(systemName: "calendar"),
                            text: "\(viewStore.item.semester) семетр",
                            backgroundColor: Color.yellow.lighter(by: 0.9),
                            accentColor: Color.yellow
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
}

// MARK: - Preview

struct StudySheetCellView_Previews: PreviewProvider {
    static var previews: some View {
        StudySheetCellView(
            store: Store(
                initialState: StudySheetCell.State(
                    item: StudySheetItem.mock1
                ),
                reducer: StudySheetCell.reducer,
                environment: StudySheetCell.Environment()
            )
        )
        .smallPreview
        .padding(16)
        .background(Color.screenBackground)
    }
}
