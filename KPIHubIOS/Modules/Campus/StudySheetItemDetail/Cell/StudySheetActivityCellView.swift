//
//  StudySheetActivityCellView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct StudySheetActivityCellView: View {

    @Environment(\.colorScheme) var colorScheme

    let store: StoreOf<StudySheetActivity>

    init(store: StoreOf<StudySheetActivity>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .light ? Color.white : Color(.tertiarySystemFill))
                    .if(colorScheme == .light) { view in
                        view
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(viewStore.activity.type)")
                        .font(.system(.body))
                        .lineLimit(2)

                    Text("Оцінка: \(viewStore.activity.mark)")
                        .font(.system(.callout).bold())
                        .lineLimit(2)

                    SmallTagView(
                        icon: Image(systemName: "calendar"),
                        text: "\(viewStore.activity.date)",
                        color: .yellow
                    )

                    SmallTagView(
                        icon: Image(systemName: "person"),
                        text: viewStore.activity.teacher,
                        color: .indigo
                    )

                    if !viewStore.activity.note.isEmpty {
                        SmallTagView(
                            icon: Image(systemName: "note.text"),
                            text: "\(viewStore.activity.note)",
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
}

// MARK: - Preview

struct StudySheetActivityCellView_Previews: PreviewProvider {
    static var previews: some View {
        StudySheetActivityCellView(
            store: Store(
                initialState: StudySheetActivity.State(
                    activity: StudySheetItem.mock1.activities[0]
                ),
                reducer: StudySheetActivity()
            )
        )
        .previewLayout(.sizeThatFits)
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
        .frame(width: 375)
        .background(Color.screenBackground)
    }
}
