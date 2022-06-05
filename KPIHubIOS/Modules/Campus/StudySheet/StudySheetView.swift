//
//  StudySheetView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import SwiftUI

extension Int {
    var stringValue: String {
        return String(self)
    }
}

struct StudySheetView: View {

    let store: Store<StudySheet.State, StudySheet.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack {
                HStack(spacing: 16) {
                    Menu {
                        ForEach(viewStore.possibleYears, id: \.self) { year in
                            Button {
                                viewStore.send(.binding(.set(\.$selectedYear, year)))
                            } label: {
                                Text("\(year)")
                            }
                        }
                        Button(
                            action: {
                                viewStore.send(.binding(.set(\.$selectedYear, nil)))
                            },
                            label: {
                                Text("Будь який")
                            }
                        )
                    } label: {
                        VStack {
                            Text("Рік:")
                                .foregroundColor(.black)
                            Text("\(viewStore.selectedYear ?? "Будь який")")
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }

                    Menu {
                        ForEach(StudySheetLesson.Semester.allCases, id: \.self) { semester in
                            Button {
                                viewStore.send(.binding(.set(\.$selectedSemester, semester.rawValue)))
                            } label: {
                                Text("\(semester.rawValue)")
                                Image(systemName: "\(semester.rawValue).square")
                            }
                        }
                        Button(
                            action: {
                                viewStore.send(.binding(.set(\.$selectedSemester, nil)))
                            },
                            label: {
                                Text("Будь який")
                            }
                        )

                    } label: {
                        VStack {
                            Text("Семестр:")
                                .foregroundColor(.black)
                            Text("\(viewStore.selectedSemester?.stringValue ?? "Будь який")")
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }

                }
                .padding()

                ScrollView {
                    LazyVStack {
                        // ITEM
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("name")
                                    .font(.system(.callout).bold())
                                    .lineLimit(2)

                                ForEach(["Teacher1", "Teacher2"], id: \.self) { teacher in
                                    SmallTagView(
                                        icon: Image(systemName: "person"),
                                        text: teacher,
                                        backgroundColor: Color(red: 247 / 255, green: 244 / 255, blue: 255 / 255),
                                        accentColor: Color(red: 91 / 255, green: 46 / 255, blue: 255 / 255)
                                    )
                                }

                                SmallTagView(
                                    icon: Image(systemName: "calendar"),
                                    text: "2018-2019 | 1 семетр",
                                    backgroundColor: Color(red: 254 / 255, green: 251 / 255, blue: 232 / 255),
                                    accentColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(16)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding()
                }
            }
            .background(Color.screenBackground)
            .navigationBarTitle("Поточний контроль")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

}

// MARK: - Preview

struct StudySheetView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StudySheetView(
                store: Store(
                    initialState: StudySheet.State(
//                        possibleYears: 
                        //                        lesson: Lesson(lessonResponse: LessonResponse.mocked[0])
                    ),
                    reducer: StudySheet.reducer,
                    environment: StudySheet.Environment(
                        //                        userDefaultsClient: .live()
                    )
                )
            )
        }
    }
}
