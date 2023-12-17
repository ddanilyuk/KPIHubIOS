//
//  EditLessonTeachersView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI
import ComposableArchitecture
import DesignKit
import Services // TODO: ?

@ViewAction(for: EditLessonTeachersFeature.self)
public struct EditLessonTeachersView: View {
    @Environment(\.colorScheme) private var colorScheme
    public let store: StoreOf<EditLessonTeachersFeature>
    
    public init(store: StoreOf<EditLessonTeachersFeature>) {
        self.store = store
    }
    
    public var body: some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
            .navigationTitle("Редагувати вчителів")
            .navigationBarTitleDisplayMode(.inline)
        // TODO: assets
//            .background(Color.screenBackground)
            .onAppear {
                send(.onAppear)
            }
    }
    
    private var content: some View {
        ScrollView {
            VStack {
                ForEach(store.teachers, id: \.self) { teacher in
                    let isSelected = store.selected.contains(teacher)
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(colorScheme == .light ? Color.white : Color(.tertiarySystemFill))
                            .shadow(
                                color: isSelected ? .orange.opacity(0.1) : .clear,
                                radius: 6,
                                x: 0,
                                y: 6
                            )

                        HStack {
                            Image(
                                systemName: isSelected ? "circle.circle.fill" : "circle"
                            )
                            .foregroundColor(isSelected ? .orange : .gray)

                            LargeTagView(
                                icon: Image(systemName: "person"),
                                text: teacher,
                                color: .indigo
                            )
                            
                            Spacer()
                        }
                        .padding(16)
                    }
                    .font(.system(.body))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .onTapGesture {
                        send(.toggleLessonTeacherTapped(name: teacher))
                    }
                }
            }
        }
    }
    
    private var cancelButton: some View {
        Button(
            action: { send(.cancelButtonTapped) },
            label: {
                Text("Скасувати")
                    .foregroundColor(.orange)
            }
        )
    }
    
    private var saveButton: some View {
        Button(
            action: { send(.saveButtonTapped) },
            label: {
                Text("Зберегти")
                    .foregroundColor(.orange)
            }
        )
    }
}

// MARK: - Preview
#Preview {
    EditLessonTeachersView(
        store: Store(initialState: EditLessonTeachersFeature.State(
            lesson: .init(lesson: Lesson(lessonResponse: LessonResponse.mocked[0]))
        )) {
            EditLessonTeachersFeature()
        }
    )
}
