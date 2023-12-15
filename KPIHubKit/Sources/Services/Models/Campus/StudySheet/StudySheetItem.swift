//
//  StudySheetItem.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import Foundation

public struct StudySheetItem: Identifiable, Equatable {
    public let id: Int
    public let year: String
    public let semester: Int
    public let name: String
    public let teachers: [String]
    public let activities: [Activity]

    public struct Activity: Codable, Equatable, Identifiable {
        public let id: Int
        public let date: String
        public let mark: String
        public let type: String
        public let teacher: String
        public let note: String

        public init(id: Int, studySheetActivityResponse: StudySheetActivityResponse) {
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
    public init(studySheetItemResponse: StudySheetItemResponse) {
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
    public static var mock1: StudySheetItem {
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

    public static var mock2: StudySheetItem {
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

    public static var mock3: StudySheetItem {
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

    public static var mock4: StudySheetItem {
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
