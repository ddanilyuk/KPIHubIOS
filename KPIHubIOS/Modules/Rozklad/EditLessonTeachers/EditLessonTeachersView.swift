//
//  EditLessonTeachersView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct EditLessonTeachersView: View {

    let store: Store<EditLessonTeachers.State, EditLessonTeachers.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack {
                    ForEach(viewStore.teachers, id: \.self) { teacher in
                        let isSelected = viewStore.selected.contains(teacher)
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white)
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
                                    text: teacher.fullName,
                                    backgroundColor: Color(red: 247 / 255, green: 244 / 255, blue: 255 / 255),
                                    accentColor: Color(red: 91 / 255, green: 46 / 255, blue: 255 / 255)
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
                        }
                    )
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(
                        action: { viewStore.send(.save) },
                        label: {
                            Text("Зберегти")
                        }
                    )
                }
            }
            .navigationTitle("Редагувати назву")
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
                    reducer: EditLessonTeachers.reducer,
                    environment: EditLessonTeachers.Environment(
                        userDefaultsClient: .live(),
                        rozkladClient: .live(userDefaultsClient: .live())
                    )
                )
            )
        }
    }
}
