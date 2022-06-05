//
//  StudySheet.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture

struct StudySheetItem: Codable {
    let lesson: StudySheetLesson
    let activities: [StudySheetActivity]
}

struct StudySheetLesson: Codable {

    let year: String
    let semester: Semester
//    let link: String
    let name: String
    let teacher: String

    enum Semester: Int, Codable, CaseIterable {
        case first = 1
        case second
    }
}

struct StudySheetActivity: Codable {

    let date: String
    let mark: String
    let type: String
    let teacher: String
    let note: String

}


struct StudySheet {

    // MARK: - State

    struct State: Equatable {

        var possibleYears: [String] = []

        @BindableState var selectedYear: String?
        @BindableState var selectedSemester: Int?

        init() {
            possibleYears = ["2018-2019", "2019-2020", "2020-2021", "2021-2022"]
        }

//        enum S
//        let
    }

    // MARK: - Action

    enum Action: Equatable, BindableAction {
        case start
        case binding(BindingAction<State>)

    }

    // MARK: - Environment

    struct Environment { }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .start:
            return .none

        case .binding:
            return .none
        }
    }
    .binding()

}
