//
//  StudySheetItemDetail.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import ComposableArchitecture

struct StudySheetItemDetail {

    // MARK: - State

    struct State: Equatable, Identifiable {
        let item: StudySheetItem

        var id: StudySheetItem.ID {
            return item.id
        }

//        init() {
//            let lesson = StudySheetLesson(
//                year: "2018-2019",
//                semester: .first,
//                name: "Англійська мова",
//                teacher: "Грабар Ольга володимирівна"
//            )
//            let activity1 = StudySheetActivity(
//                date: "09-12-2018",
//                mark: "28",
//                type: "Диференційований залік",
//                teacher: "Блажієвська Ірина Петрівна",
//                note: ""
//            )
//            let activity2 = StudySheetActivity(
//                date: "09-12-2018",
//                mark: "95",
//                type: "Модульна контрольна робота",
//                teacher: "Блажієвська Ірина Петрівна",
//                note: ""
//            )
//            self.item = .init(lesson: lesson, activities: [activity1, activity2])
//        }
    }

    // MARK: - Action

    enum Action: Equatable {
        case start
    }

    // MARK: - Environment

    struct Environment {
        
    }

    // MARK: - Reducer

    static let reducer = Reducer<State, Action, Environment> { _, action, _ in
        switch action {
        case .start:
            return .none
        }
    }

}
