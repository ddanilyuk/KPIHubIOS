//
//  StudySheetItem.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import Foundation

public struct StudySheetItem: Identifiable, Equatable {
    public let id: Int
    let year: String
    let semester: Int
    let name: String
    let teachers: [String]
    let activities: [Activity]

    struct Activity: Codable, Equatable, Identifiable {
        let id: Int
        let date: String
        let mark: String
        let type: String
        let teacher: String
        let note: String

        init(id: Int, studySheetActivityResponse: StudySheetActivityResponse) {
            self.id = id
            self.date = studySheetActivityResponse.date
            self.mark = studySheetActivityResponse.mark
            self.type = studySheetActivityResponse.type
            self.teacher = studySheetActivityResponse.teacher
            self.note = studySheetActivityResponse.note
        }
    }
}

extension StudySheetItem {
    init(studySheetItemResponse: StudySheetItemResponse) {
        self.id = studySheetItemResponse.id
        self.year = studySheetItemResponse.year
        self.semester = studySheetItemResponse.semester
        self.name = studySheetItemResponse.name
        self.teachers = studySheetItemResponse.teachers

        self.activities = studySheetItemResponse.activities
            .enumerated()
            .map { Activity(id: $0, studySheetActivityResponse: $1) }
    }
}

// MARK: StudySheetItem + Mock

extension StudySheetItem {
    static var mock1: StudySheetItem {
        StudySheetItem(
            studySheetItemResponse: StudySheetItemResponse(
                id: 1,
                year: "2018-2019",
                semester: 1,
                link: "",
                name: "Англійська мова",
                teachers: ["Грабар Ольга володимирівна", "Сергеєва Оксана Олексіївна"],
                activities: [
                    .init(
                        date: "2018-2019",
                        mark: "15", 
                        type: "Test",
                        teacher: "Сергеєва Оксана Олексіївна",
                        note: ""
                    )
                ]
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
}
