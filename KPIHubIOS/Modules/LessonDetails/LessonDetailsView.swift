//
//  LessonDetailsView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 17.12.2023.
//

import SwiftUI
import ComposableArchitecture
import LessonDetailsFeature
import DesignKit
import GeneralServices // TODO: ?

@ViewAction(for: LessonDetailsFeature.self)
struct LessonDetailsView: View {
    @Bindable var store: StoreOf<LessonDetailsFeature>
    
    init(store: StoreOf<LessonDetailsFeature>) {
        self.store = store
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                LessonDetailsTitleView(
                    title: store.lesson.names.joined(separator: ", "),
                    isEditing: store.isEditing
                )
                .onTapGesture {
                    send(.editNamesButtonTapped)
                }

//                LessonDetailsDateAndTimeSection(
//                    lessonPositionDescription: store.lesson.position.description,
//                    lessonWeek: store.lesson.week,
//                    lessonDay: store.lesson.day,
//                    mode: store.mode
//                )

                if let teachers = store.lesson.teachers, !teachers.isEmpty {
                    LessonDetailsTeacherSection(
                        teachers: teachers,
                        isEditing: store.isEditing
                    )
                    .onTapGesture {
                        send(.editTeachersButtonTapped)
                    }
                }
                
                if !store.lesson.type.isEmpty {
                    LessonDetailsTypeSection(
                        type: store.lesson.type
                    )
                }
                
                if let locations = store.lesson.locations, !locations.isEmpty {
                    LessonDetailsLocationsSection(
                        locations: locations
                    )
                }
                
                if store.isEditing {
                    Button("ВИДАЛИТИ", role: .destructive) {
                        send(.deleteLessonButtonTapped)
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
        .animation(.default, value: store.isEditing)
        .onAppear {
            send(.onAppear)
        }
        // TODO: assets
//        .background(Color.screenBackground)
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
        // TODO: Generic destination?
        .sheet(
            item: $store.scope(
                state: \.destination?.editLessonNames,
                action: \.destination.editLessonNames
            )
        ) { store in
            NavigationStack {
                EditLessonNamesView(store: store)
            }
        }
//        .sheet(
//            item: $store.scope(
//                state: \.destination?.editLessonTeachers,
//                action: \.destination.editLessonTeachers
//            )
//        ) { store in
//            NavigationStack {
//                EditLessonTeachersView(store: store)
//            }
//        }
        .navigationTitle("Деталі")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    var toolbar: some View {
        switch store.isEditing {
        case true:
            Button(
                action: { send(.endEditingButtonTapped) },
                label: { Text("Готово") }
            )

        case false:
            Menu(
                content: {
                    Button(
                        action: { send(.startEditingButtonTapped) },
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

// MARK: - Preview
#Preview {
    NavigationStack {
        LessonDetailsView(
            store: Store(
                initialState: LessonDetailsFeature.State(
                    lesson: .init(lesson: Lesson(lessonResponse: LessonResponse.mocked[0]))
                )
            ) {
                LessonDetailsFeature()
            }
        )
    }
}
