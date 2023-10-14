//
//  EditLessonNamesView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI
import ComposableArchitecture
import Common

struct EditLessonNamesView: View {
    struct ViewState: Equatable {
        let names: [String]
        let selected: [String]
        
        init(state: EditLessonNames.State) {
            self.names = state.names
            self.selected = state.selected
        }
    }
    
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var viewStore: ViewStore<ViewState, EditLessonNames.Action.View>

    init(store: StoreOf<EditLessonNames>) {
        viewStore = ViewStore(store, observe: ViewState.init, send: { .view($0) })
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
            .background(Color.screenBackground)
            .onAppear {
                viewStore.send(.onAppear)
            }
    }
    
    private var content: some View {
        ScrollView {
            VStack {
                ForEach(viewStore.names, id: \.self) { name in
                    let isSelected = viewStore.selected.contains(name)
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
                        viewStore.send(.toggleLessonNameTapped(name: name))
                    }
                }
            }
        }
    }
    
    private var cancelButton: some View {
        Button(
            action: { viewStore.send(.cancelButtonTapped) },
            label: {
                Text("Скасувати")
                    .foregroundColor(.orange)
            }
        )
    }
    
    private var saveButton: some View {
        Button(
            action: { viewStore.send(.saveButtonTapped) },
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
