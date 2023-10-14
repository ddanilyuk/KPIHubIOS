//
//  StudySheetView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import SwiftUI

struct StudySheetView: View {
    struct ViewState: Equatable {
        // TODO: Check this
        var cells: IdentifiedArrayOf<StudySheetCell.State>
        var possibleYears: [String] = []
        var possibleSemesters: [Int] = []
        @BindingViewState var selectedYear: String?
        @BindingViewState var selectedSemester: Int?
        
        init(state: BindingViewStore<StudySheet.State>) {
            cells = state.cells
            possibleYears = state.possibleYears
            possibleSemesters = state.possibleSemesters
            _selectedYear = state.$selectedYear
            _selectedSemester = state.$selectedSemester
        }
    }
    
    @ObservedObject private var viewStore: ViewStore<ViewState, StudySheet.Action.View>
    private let store: StoreOf<StudySheet>
    
    init(store: StoreOf<StudySheet>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { ViewState(state: $0) }, send: { .view($0) })
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            header
            
            scrollView
        }
        .navigationBarTitle("Поточний контроль")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.screenBackground)
        .onAppear {
            viewStore.send(.onAppear)
        }
    }
    
    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            possibleYearsMenu
            
            possibleSemestersMenu
        }
        .frame(height: 50)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    private var scrollView: some View {
        ScrollView(.vertical) {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEachStore(
                    store.scope(
                        state: \.cells,
                        action: StudySheet.Action.cells(id:action:)
                    ),
                    content: StudySheetCellView.init(store:)
                )
            }
        }
        .animation(Animation.default, value: viewStore.cells)
    }
    
    private var possibleYearsMenu: some View {
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
    }
    
    private var possibleSemestersMenu: some View {
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
}

#Preview {
    NavigationStack {
        StudySheetView(
            store: Store(initialState: StudySheet.State(
                items: [StudySheetItem.mock1, .mock2, .mock3, .mock4]
            )) {
                StudySheet()
            }
        )
    }
}
