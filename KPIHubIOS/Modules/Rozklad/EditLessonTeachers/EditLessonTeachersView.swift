//
//  EditLessonTeachersView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct EditLessonTeachersView: View {

    @Environment(\.colorScheme) var colorScheme

    let store: Store<EditLessonTeachers.State, EditLessonTeachers.Action>

    init(store: Store<EditLessonTeachers.State, EditLessonTeachers.Action>) {
        self.store = store
    }

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack {
                    ForEach(viewStore.teachers, id: \.self) { teacher in
                        let isSelected = viewStore.selected.contains(teacher)
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
                            viewStore.send(.toggle(teacher))
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(
                        action: { viewStore.send(.cancel) },
                        label: {
                            Text("Скасувати")
                                .foregroundColor(.orange)
                        }
                    )
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: { viewStore.send(.save) },
                        label: {
                            Text("Зберегти")
                                .foregroundColor(.orange)
                        }
                    )
                }
            }
            .navigationTitle("Редагувати вчителів")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.screenBackground)
        }
    }

}

// MARK: - Preview

struct EditLessonTeachersView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditLessonTeachersView(
                store: Store(
                    initialState: EditLessonTeachers.State(
                        lesson: .init(lessonResponse: LessonResponse.mocked[0])
                    ),
                    reducer: EditLessonTeachers()
                )
            )
        }
    }
}
