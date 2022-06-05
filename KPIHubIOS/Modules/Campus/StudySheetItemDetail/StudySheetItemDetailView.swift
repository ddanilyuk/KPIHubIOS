//
//  StudySheetItemDetailView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct StudySheetItemDetailView: View {

    let store: Store<StudySheetItemDetail.State, StudySheetItemDetail.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                LazyVStack {
                    // ITEM
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(viewStore.item.activities[0].type)")
                                .font(.system(.body))
                                .lineLimit(2)

                            Text("Оцінка: \(viewStore.item.activities[0].mark)")
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
                                text: "\(viewStore.item.activities[0].date)",
                                backgroundColor: Color(red: 254 / 255, green: 251 / 255, blue: 232 / 255),
                                accentColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
                            )

                            if !viewStore.item.activities[0].note.isEmpty {
                                SmallTagView(
                                    icon: Image(systemName: "note.text"),
                                    text: "\(viewStore.item.activities[0].note)",
                                    backgroundColor: Color(red: 254 / 255, green: 251 / 255, blue: 232 / 255),
                                    accentColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                    }
                    Spacer(minLength: 0)
                }
                .padding()
                .navigationBarTitle("\(viewStore.item.lesson.name)")
                .navigationBarTitleDisplayMode(.inline)

            }
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
                        //                        possibleYears:
                        //                        lesson: Lesson(lessonResponse: LessonResponse.mocked[0])
                    ),
                    reducer: StudySheetItemDetail.reducer,
                    environment: StudySheetItemDetail.Environment(
                        //                        userDefaultsClient: .live()
                    )
                )
            )
        }
    }
}

