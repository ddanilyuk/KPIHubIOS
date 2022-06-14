//
//  EditLessonNamesView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI
import ComposableArchitecture

struct EditLessonNamesView: View {

    let store: Store<EditLessonNames.State, EditLessonNames.Action>

    var body: some View {
        WithViewStore(store) { viewStore in
            ScrollView {
                VStack {
                    ForEach(viewStore.names, id: \.self) { name in
                        let isSelected = viewStore.selected.contains(name)
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

                                Text("\(name)")

                                Spacer()
                            }
                            .padding(16)
                        }
                        .font(.system(.body))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 4)
                        .onTapGesture {
                            viewStore.send(.toggle(name))
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

struct EditLessonNamesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EditLessonNamesView(
                store: Store(
                    initialState: EditLessonNames.State(
                        lesson: .init(lessonResponse: LessonResponse.mocked[0])
                    ),
                    reducer: EditLessonNames.reducer,
                    environment: EditLessonNames.Environment(
                        userDefaultsClient: .live(),
                        rozkladClient: .live(userDefaultsClient: .live())
                    )
                )
            )
        }
    }
}
