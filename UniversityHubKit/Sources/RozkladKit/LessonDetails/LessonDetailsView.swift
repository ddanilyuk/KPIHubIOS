//
//  LessonDetailsView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

//import SwiftUI
//import ComposableArchitecture
//import DesignKit
//import Services // TODO: ?
//
//@ViewAction(for: LessonDetails.self)
//struct LessonDetailsView: View {
//    @Bindable var store: StoreOf<LessonDetails>
//    
//    init(store: StoreOf<LessonDetails>) {
//        self.store = store
//    }
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 16) {
//                LessonDetailsTitleView(
//                    title: store.lesson.names.joined(separator: ", "),
//                    isEditing: store.isEditing
//                )
//                .onTapGesture {
//                    send(.editNamesButtonTapped)
//                }
//
//                LessonDetailsDateAndTimeSection(
//                    lessonPositionDescription: store.lesson.position.description,
//                    lessonWeek: store.lesson.week,
//                    lessonDay: store.lesson.day,
//                    mode: store.mode
//                )
//
//                if !store.lesson.isTeachersEmpty {
//                    LessonDetailsTeacherSection(
//                        teachers: store.lesson.teachers ?? [],
//                        isEditing: store.isEditing
//                    )
//                    .onTapGesture {
//                        send(.editTeachersButtonTapped)
//                    }
//                }
//
//                if !store.lesson.isTypeEmpty {
//                    LessonDetailsTypeSection(
//                        type: store.lesson.type
//                    )
//                }
//
//                if !store.lesson.isLocationsEmpty {
//                    LessonDetailsLocationsSection(
//                        locations: store.lesson.locations ?? []
//                    )
//                }
//                
//                if store.isEditing {
//                    Button("ВИДАЛИТИ", role: .destructive) {
//                        send(.deleteLessonButtonTapped)
//                    }
//                    .buttonStyle(.borderedProminent)
//                }
//            }
//            .padding(16)
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                toolbar
//            }
//        }
//        .animation(.default, value: store.isEditing)
//        .onAppear {
//            send(.onAppear)
//        }
//        // TODO: assets
////        .background(Color.screenBackground)
//        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
//        .sheet(
//            item: $store.scope(
//                state: \.destination?.editLessonNames,
//                action: \.destination.editLessonNames
//            )
//        ) { store in
//            NavigationStack {
//                EditLessonNamesView(store: store)
//            }
//        }
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
//        .navigationTitle("Деталі")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//
//    @ViewBuilder
//    var toolbar: some View {
//        switch store.isEditing {
//        case true:
//            Button(
//                action: { send(.endEditingButtonTapped) },
//                label: { Text("Готово") }
//            )
//
//        case false:
//            Menu(
//                content: {
//                    Button(
//                        action: { send(.startEditingButtonTapped) },
//                        label: {
//                            Text("Редагувати")
//                            Image(systemName: "pencil")
//                        }
//                    )
//                },
//                label: { Image(systemName: "ellipsis") }
//            )
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    NavigationStack {
//        LessonDetailsView(
//            store: Store(
//                initialState: LessonDetails.State(
//                    lesson: Lesson(lessonResponse: LessonResponse.mocked[0])
//                )
//            ) {
//                LessonDetails()
//            }
//        )
//    }
//}
