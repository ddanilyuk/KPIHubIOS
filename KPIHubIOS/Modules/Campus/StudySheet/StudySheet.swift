//
//  StudySheet.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture
import IdentifiedCollections



struct StudySheetResponse: Codable, Equatable {
    let studySheet: [StudySheetItemResponse]
}

struct StudySheetItemResponse: Codable, Equatable {

    let id: Int
    let year: String
    let semester: Int
    let link: String
    let name: String
    let teachers: [String]

    let activities: [StudySheetActivityResponse]
}

struct StudySheetLessonResponse: Codable, Equatable {

}

struct StudySheetActivityResponse: Codable, Equatable {

    let date: String
    let mark: String
    let type: String
    let teacher: String
    let note: String

}

struct StudySheetItem: Identifiable, Equatable {

    let id: Int
    let year: String
    let semester: Int
    let name: String
    let teachers: [String]
    let activities: [Activity]

    let studySheetItemResponse: StudySheetItemResponse

    static var mock1: StudySheetItem {
        StudySheetItem(
            studySheetItemResponse: StudySheetItemResponse(
                id: 1,
                year: "2018-2019",
                semester: 1,
                link: "",
                name: "Англійська мова",
                teachers: ["Грабар Ольга володимирівна", "Сергеєва Оксана Олексіївна"],
                activities: []
            )
        )
    }

    static var mock2: StudySheetItem {
        StudySheetItem(
            studySheetItemResponse: StudySheetItemResponse(
                id: 2,
                year: "2020-2021",
                semester: 2,
                link: "",
                name: "Пред мет тут",
                teachers: ["Грабар Ольга володимирівна"],
                activities: []
            )
        )
    }

    static var mock3: StudySheetItem {
        StudySheetItem(
            studySheetItemResponse: StudySheetItemResponse(
                id: 3,
                year: "2020-2021",
                semester: 1,
                link: "",
                name: "Пред мет тут",
                teachers: ["Грабар Ольга володимирівна"],
                activities: []
            )
        )
    }

    static var mock4: StudySheetItem {
        StudySheetItem(
            studySheetItemResponse: StudySheetItemResponse(
                id: 4,
                year: "2020-2021",
                semester: 2,
                link: "",
                name: "Пред мет тут",
                teachers: ["Грабар Ольга володимирівна"],
                activities: []
            )
        )
    }

    struct Activity: Codable, Equatable {

        let date: String
        let mark: String
        let type: String
        let teacher: String
        let note: String

    }
}

extension StudySheetItem {

    init(studySheetItemResponse: StudySheetItemResponse) {
        self.id = studySheetItemResponse.id
        self.year = studySheetItemResponse.year
        self.semester = studySheetItemResponse.semester
        self.name = studySheetItemResponse.name
        self.teachers = studySheetItemResponse.teachers

        self.activities = []

        self.studySheetItemResponse = studySheetItemResponse
    }
}

//    enum Semester: Int, Codable, CaseIterable {
//        case undefined = 0
//        case first = 1
//        case second = 2
//    }


struct StudySheet {

    // MARK: - State

    struct State: Equatable {

        var possibleYears: [String] = []
        var possibleSemesters: [Int] = []

        var items: [StudySheetItem]
        var sortedItems: [StudySheetItem]
        var cells: IdentifiedArrayOf<StudySheetCell.State>

        @BindableState var selectedYear: String?
        @BindableState var selectedSemester: Int?

        init(items: [StudySheetItem]) {
            self.items = items
            self.sortedItems = items
            self.cells = IdentifiedArray(uniqueElements: sortedItems.map { StudySheetCell.State(item: $0) })

            possibleYears = Set(items.map { $0.year }).sorted(by: <)
            possibleSemesters = Set(items.map { $0.semester }).sorted(by: <)
        }
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case onAppear

        case cells(id: StudySheetCell.State.ID, action: StudySheetCell.Action)
        
        case binding(BindingAction<State>)
        case routeAction(RouteAction)

        enum RouteAction: Equatable {
            case itemDetail
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
            state.sortedItems = state.items.filter({ item in
                switch (state.selectedYear, state.selectedSemester) {
                case (.none, .none):
                    return true
                case let (.some(selectedY), .none):
                    return item.year == selectedY
                case let (.none, .some(selectedS)):
                    return item.semester == selectedS
                case let (.some(selectedY), .some(selectedS)):
                    return item.year == selectedY && item.semester == selectedS
                }
            })
            state.cells = IdentifiedArray(uniqueElements: state.sortedItems.map { StudySheetCell.State(item: $0) })
            return .none

        case .binding(\.$selectedSemester):
            state.sortedItems = state.items.filter({ item in
                switch (state.selectedYear, state.selectedSemester) {
                case (.none, .none):
                    return true
                case let (.some(selectedY), .none):
                    return item.year == selectedY
                case let (.none, .some(selectedS)):
                    return item.semester == selectedS
                case let (.some(selectedY), .some(selectedS)):
                    return item.year == selectedY && item.semester == selectedS
                }
            })
            state.cells = IdentifiedArray(uniqueElements: state.sortedItems.map { StudySheetCell.State(item: $0) })
            return .none

        case let .cells(id, .onTap):
            print("Tapped id")
            return .none

        case .binding:
            return .none

        case .routeAction:
            return .none
        }
    }
    .binding()

}
