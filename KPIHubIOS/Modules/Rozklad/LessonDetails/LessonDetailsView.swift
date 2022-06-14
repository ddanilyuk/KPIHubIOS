//
//  LessonDetailsView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct LessonDetailsView: View {

    let store: Store<LessonDetails.State, LessonDetails.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    TitleView(
                        title: viewStore.lesson.names.joined(separator: ", "),
                        isEditing: viewStore.isEditing,
                        onTap: { viewStore.send(.editNames) }
                    )

                    DateAndTime(
                        lessonPositionDescription: viewStore.lesson.position.description,
                        lessonWeek: viewStore.lesson.week,
                        lessonDay: viewStore.lesson.day
                    )

                    TeacherSection(
                        teachers: viewStore.lesson.teachers ?? [],
                        isEditing: viewStore.isEditing,
                        onTap: { viewStore.send(.editTeachers) }
                    )

                    TypeSection(
                        type: "Практика"
                    )

                    LocationsSection(
                        locations: viewStore.lesson.locations ?? [],
                        onTap: {}
                    )
                }
                .padding(16)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbar(store: store)
                }
            }
            .animation(.default, value: viewStore.state.isEditing)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
        .background(Color.screenBackground)
        .navigationTitle("Деталі")
        .navigationBarTitleDisplayMode(.inline)
    }

    func toolbar(store: Store<LessonDetails.State, LessonDetails.Action>) -> some View {
        WithViewStore(store) { viewStore in
            switch viewStore.state.isEditing {
            case true:
                Button(
                    action: { viewStore.send(.binding(.set(\.$isEditing, false))) },
                    label: { Text("Готово") }
                )

            case false:
                Menu(
                    content: {
                        Button(
                            action: { viewStore.send(.binding(.set(\.$isEditing, true))) },
                            label: {
                                Text("Редагувати")
                                Image(systemName: "pencil")
                            }
                        )
                    },
                    label: { Image(systemName: "ellipsis") }
                )
            }
        }
    }
    
}

// MARK: - Preview

struct LessonDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LessonDetailsView(
                store: Store(
                    initialState: LessonDetails.State(
                        lesson: Lesson(lessonResponse: LessonResponse.mocked[0])
                    ),
                    reducer: LessonDetails.reducer,
                    environment: LessonDetails.Environment(
                        userDefaultsClient: .live(),
                        rozkladClient: .live(userDefaultsClient: .live())
                    )
                )
            )
        }
    }
}
