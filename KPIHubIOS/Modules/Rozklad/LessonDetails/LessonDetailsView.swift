//
//  LessonDetailsView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct LessonDetailsView: View {

    let store: StoreOf<LessonDetails>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    LessonDetailsTitleView(
                        title: viewStore.lesson.names.joined(separator: ", "),
                        isEditing: viewStore.isEditing
                    )
                    .onTapGesture {
                        viewStore.send(.editNames)
                    }

                    LessonDetailsDateAndTimeSection(
                        lessonPositionDescription: viewStore.lesson.position.description,
                        lessonWeek: viewStore.lesson.week,
                        lessonDay: viewStore.lesson.day,
                        mode: viewStore.mode
                    )

                    if viewStore.showTeachers {
                        LessonDetailsTeacherSection(
                            teachers: viewStore.lesson.teachers ?? [],
                            isEditing: viewStore.isEditing
                        )
                        .onTapGesture {
                            viewStore.send(.editTeachers)
                        }
                    }

                    if viewStore.showType {
                        LessonDetailsTypeSection(
                            type: viewStore.lesson.type
                        )
                    }

                    if viewStore.showLocations {
                        LessonDetailsLocationsSection(
                            locations: viewStore.lesson.locations ?? []
                        )
                    }
                    
                    if viewStore.isEditing {
                        Button("ВИДАЛИТИ", role: .destructive) {
                            viewStore.send(.deleteLessonTapped)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(16)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbar
                }
            }
            .animation(.default, value: viewStore.state.isEditing)
            .onAppear {
                viewStore.send(.onAppear)
            }
            .background(Color.screenBackground)
            .alert(
                self.store.scope(state: \.alert),
                dismiss: .dismissAlert
            )
            .navigationTitle("Деталі")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    var toolbar: some View {
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
                    reducer: LessonDetails()
                )
            )
        }
    }
}
