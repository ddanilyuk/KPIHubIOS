//
//  StudySheet.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import IdentifiedCollections

struct StudySheet {

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

            sortedItems = self.items.filter { item in
                switch (selectedYear, selectedSemester) {
                case (.none, .none):
                    return true
                case let (.some(selectedYear), .none):
                    return item.year == selectedYear
                case let (.none, .some(selectedSemester)):
                    return item.semester == selectedSemester
                case let (.some(selectedYear), .some(selectedSemester)):
                    return item.year == selectedYear && item.semester == selectedSemester
                }
            }
            cells = IdentifiedArray(
                uniqueElements: sortedItems.map { StudySheetCell.State(item: $0) }
            )
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

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { state, action, _ in
        switch action {
        case .onAppear:
            return .none

        case .binding(\.$selectedYear):
            return Effect(value: .sortCells)

        case .binding(\.$selectedSemester):
            return Effect(value: .sortCells)

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
    .binding()

}
