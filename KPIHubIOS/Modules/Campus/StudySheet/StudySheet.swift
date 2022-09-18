//
//  StudySheet.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import IdentifiedCollections

struct StudySheet: ReducerProtocol {

    // MARK: - State

    struct State: Equatable {

        var items: IdentifiedArrayOf<StudySheetItem>
        var sortedItems: IdentifiedArrayOf<StudySheetItem>
        var cells: IdentifiedArrayOf<StudySheetCell.State>

        var possibleYears: [String] = []
        var possibleSemesters: [Int] = []

        @BindableState var selectedYear: String?
        @BindableState var selectedSemester: Int?

        init(items: [StudySheetItem]) {
            self.items = IdentifiedArray(uniqueElements: items)

            possibleYears = Set(items.map { $0.year }).sorted(by: <)
            possibleSemesters = Set(items.map { $0.semester }).sorted(by: <)

            selectedYear = possibleYears.last
            selectedSemester = nil

            sortedItems = []
            cells = []
        }
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case onAppear

        case sortCells
        case cells(id: StudySheetCell.State.ID, action: StudySheetCell.Action)
        
        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case openDetail(StudySheetItem)
        }
    }

    // MARK: - Reducer
    
    @Dependency(\.analyticsClient) var analyticsClient
    
    var body: some ReducerProtocol<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                analyticsClient.track(Event.Campus.studySheetAppeared)
                return Effect(value: .sortCells)
                    .animation(nil)

            case .binding(\.$selectedYear):
                return Effect(value: .sortCells)
                    .animation()

            case .binding(\.$selectedSemester):
                return Effect(value: .sortCells)
                    .animation()

            case .sortCells:
                state.sortedItems = state.items.filter({ item in
                    switch (state.selectedYear, state.selectedSemester) {
                    case (.none, .none):
                        return true
                    case let (.some(selectedYear), .none):
                        return item.year == selectedYear
                    case let (.none, .some(selectedSemester)):
                        return item.semester == selectedSemester
                    case let (.some(selectedYear), .some(selectedSemester)):
                        return item.year == selectedYear && item.semester == selectedSemester
                    }
                })
                state.cells = IdentifiedArray(
                    uniqueElements: state.sortedItems.map { StudySheetCell.State(item: $0) }
                )
                return .none

            case let .cells(id, .onTap):
                guard let selectedItem = state.items[id: id] else {
                    return .none
                }
                return Effect(value: .routeAction(.openDetail(selectedItem)))

            case .binding:
                return .none

            case .routeAction:
                return .none
            }
        }
    }

}
