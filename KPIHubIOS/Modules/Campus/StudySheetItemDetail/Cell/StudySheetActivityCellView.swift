//
//  StudySheetActivityCellView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct StudySheetActivityCellView: View {

    let store: Store<StudySheetActivity.State, StudySheetActivity.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                VStack(alignment: .leading, spacing: 10) {
                    Text("\(viewStore.activity.type)")
                        .font(.system(.body))
                        .lineLimit(2)

                    Text("Оцінка: \(viewStore.activity.mark)")
                        .font(.system(.callout).bold())
                        .lineLimit(2)

                    SmallTagView(
                        icon: Image(systemName: "person"),
                        text: "teacher",
                        backgroundColor: Color(red: 247 / 255, green: 244 / 255, blue: 255 / 255),
                        accentColor: Color(red: 91 / 255, green: 46 / 255, blue: 255 / 255)
                    )

                    SmallTagView(
                        icon: Image(systemName: "calendar"),
                        text: "\(viewStore.activity.date)",
                        backgroundColor: Color(red: 254 / 255, green: 251 / 255, blue: 232 / 255),
                        accentColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
                    )

                    if !viewStore.activity.note.isEmpty {
                        SmallTagView(
                            icon: Image(systemName: "note.text"),
                            text: "\(viewStore.activity.note)",
                            backgroundColor: Color(red: 254 / 255, green: 251 / 255, blue: 232 / 255),
                            accentColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
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
                reducer: StudySheetActivity.reducer,
                environment: StudySheetActivity.Environment()
            )
        )
        .previewLayout(.sizeThatFits)
        .fixedSize(horizontal: false, vertical: true)
        .padding(16)
        .frame(width: 375)
        .background(Color.screenBackground)
    }
}
