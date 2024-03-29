//
//  StudySheetView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import SwiftUI

extension Int {
    var stringValue: String {
        return String(self)
    }
}

struct StudySheetView: View {

    let store: StoreOf<StudySheet>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 16) {
                    Menu {
                        ForEach(viewStore.possibleYears, id: \.self) { year in
                            Button {
                                viewStore.send(.binding(.set(\.$selectedYear, year)))
                            } label: {
                                Text("\(year)")
                            }
                        }
                        Button(
                            action: {
                                viewStore.send(.binding(.set(\.$selectedYear, nil)))
                            },
                            label: {
                                Text("Будь який")
                            }
                        )
                    } label: {
                        VStack {
                            Text("Рік:")
                                .foregroundColor(.primary)
                            Text("\(viewStore.selectedYear ?? "Будь який")")
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }

                    Menu {
                        ForEach(viewStore.possibleSemesters, id: \.self) { semester in
                            Button {
                                viewStore.send(.binding(.set(\.$selectedSemester, semester)))
                            } label: {
                                Text("\(semester)")
                            }
                        }
                        Button(
                            action: {
                                viewStore.send(.binding(.set(\.$selectedSemester, nil)))
                            },
                            label: {
                                Text("Будь який")
                            }
                        )

                    } label: {
                        VStack {
                            Text("Семестр:")
                                .foregroundColor(.primary)
                            Text("\(viewStore.selectedSemester?.stringValue ?? "Будь який")")
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }
                }
                .frame(height: 50)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEachStore(
                            self.store.scope(
                                state: \StudySheet.State.cells,
                                action: StudySheet.Action.cells(id:action:)
                            ),
                            content: StudySheetCellView.init(store:)
                        )
                    }
                }
                .animation(Animation.default, value: viewStore.cells)
            }
            .navigationBarTitle("Поточний контроль")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.screenBackground)
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }

}

// MARK: - Preview

struct StudySheetView_Previews: PreviewProvider {
    static var previews: some View {
        TabView {
            NavigationView {
                StudySheetView(
                    store: Store(
                        initialState: StudySheet.State(
                            items: [StudySheetItem.mock1, .mock2, .mock3, .mock4]
                        ),
                        reducer: StudySheet()
                    )
                )
            }
            .tabItem {
                Text("test")
            }
        }

    }
}
