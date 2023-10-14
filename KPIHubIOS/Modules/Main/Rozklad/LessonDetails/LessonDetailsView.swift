//
//  LessonDetailsView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI
import ComposableArchitecture

struct LessonDetailsView: View {
    struct ViewState: Equatable {
        let lesson: Lesson
        let mode: LessonMode
        let isEditing: Bool
        
        var showTeachers: Bool {
            !lesson.isTeachersEmpty
        }
        var showLocations: Bool {
            !lesson.isLocationsEmpty
        }
        var showType: Bool {
            !lesson.isTypeEmpty
        }
        
        init(state: LessonDetails.State) {
            lesson = state.lesson
            mode = state.mode
            isEditing = state.isEditing
        }
    }
    
    private let store: StoreOf<LessonDetails>
    @ObservedObject private var viewStore: ViewStore<ViewState, LessonDetails.Action.View>
    
    init(store: StoreOf<LessonDetails>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: ViewState.init, send: { .view($0) })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                LessonDetailsTitleView(
                    title: viewStore.lesson.names.joined(separator: ", "),
                    isEditing: viewStore.isEditing
                )
                .onTapGesture {
                    viewStore.send(.editNamesButtonTapped)
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
                        viewStore.send(.editTeachersButtonTapped)
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
                        viewStore.send(.deleteLessonButtonTapped)
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
        .alert(store: store.scope(state: \.$alert, action: { .alert($0) }))
        .navigationTitle("Деталі")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    var toolbar: some View {
        switch viewStore.state.isEditing {
        case true:
            Button(
                action: { viewStore.send(.endEditingButtonTapped) },
                label: { Text("Готово") }
            )

        case false:
            Menu(
                content: {
                    Button(
                        action: { viewStore.send(.startEditingButtonTapped) },
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
                initialState: LessonDetails.State(
                    lesson: Lesson(lessonResponse: LessonResponse.mocked[0])
                )
            ) {
                LessonDetails()
            }
        )
    }
}
