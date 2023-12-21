//
//  StudySheet.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import IdentifiedCollections
import GeneralServices
import CampusModels

struct StudySheet: Reducer {
    struct State: Equatable {
        var items: IdentifiedArrayOf<StudySheetItem>
        var sortedItems: IdentifiedArrayOf<StudySheetItem>
        var cells: IdentifiedArrayOf<StudySheetCell.State>

        var possibleYears: [String] = []
        var possibleSemesters: [Int] = []

        @BindingState var selectedYear: String?
        @BindingState var selectedSemester: Int?

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
    
    enum Action: Equatable {
        case sortCells
        case cells(id: StudySheetCell.State.ID, action: StudySheetCell.Action)

        case view(View)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case openDetail(StudySheetItem)
        }
        
        enum View: Equatable, BindableAction {
            case onAppear
            case binding(BindingAction<State>)
        }
    }
    
    @Dependency(\.analyticsService) var analyticsService
    
    var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)
        
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                analyticsService.track(Event.Campus.studySheetAppeared)
                return .send(.sortCells, animation: nil)

            case .view(.binding(\.$selectedYear)):
                return .send(.sortCells, animation: .default)

            case .view(.binding(\.$selectedSemester)):
                return .send(.sortCells, animation: .default)

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
                return .send(.routeAction(.openDetail(selectedItem)))

            case .view:
                return .none

            case .routeAction:
                return .none
            }
        }
    }
}
