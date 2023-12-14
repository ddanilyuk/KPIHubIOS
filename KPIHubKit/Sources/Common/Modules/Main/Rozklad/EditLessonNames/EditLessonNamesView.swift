//
//  EditLessonNamesView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI
import ComposableArchitecture

@ViewAction(for: EditLessonNames.self)
struct EditLessonNamesView: View {
    @Environment(\.colorScheme) private var colorScheme
    let store: StoreOf<EditLessonNames>

    init(store: StoreOf<EditLessonNames>) {
        self.store = store
    }

    var body: some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
            .navigationTitle("Редагувати назву")
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
                ForEach(store.names, id: \.self) { name in
                    let isSelected = store.selected.contains(name)
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

                            Text("\(name)")

                            Spacer()
                        }
                        .padding(16)
                    }
                    .font(.system(.body))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                    .onTapGesture {
                        send(.toggleLessonNameTapped(name: name))
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
    EditLessonNamesView(
        store: Store(initialState: EditLessonNames.State(
            lesson: Lesson(lessonResponse: LessonResponse.mocked[0])
        )) {
            EditLessonNames()
        }
    )
}
