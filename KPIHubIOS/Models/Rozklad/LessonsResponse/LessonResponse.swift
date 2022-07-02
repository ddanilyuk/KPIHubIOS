//
//  Lesson.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.05.2022.
//

import Foundation

struct LessonResponse: Equatable {

    // MARK: - Position

    enum Position: Int, Codable, CaseIterable, Equatable {
        case first = 1
        case second
        case third
        case fourth
        case fifth
        case sixth
    }

    // MARK: - Day

    enum Day: Int, Codable, CaseIterable, Equatable {
        case monday = 1
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }

    // MARK: - Week

    enum Week: Int, Codable, Equatable, CaseIterable {
        case first = 1
        case second
    }

    let names: [String]
    let teachers: [String]?
    let locations: [String]?
    let type: String

    let week: Week
    let day: Day
    let position: Position
}

// MARK: - Codable

extension LessonResponse: Codable {

}

// MARK: - Hashable

extension LessonResponse: Hashable {

}

// MARK: - Identifiable

extension LessonResponse: Identifiable {

    var id: Int {
        hashValue
    }

}

// MARK: - Mock

extension LessonResponse {

    static let mocked: [LessonResponse] = [
        LessonResponse(
            names: ["First Monday very long", "First 2213 very long", "First aallala very long"],
            teachers: [
                "асистент Каплунов Артем Володимирович",
                "доцент Долголенко Олександр Миколайович"
            ],
            locations: [],
            type: "Лекція",
            week: .first,
            day: .monday,
            position: .first
        ),
        LessonResponse(
            names: ["Second Monday"],
            teachers: [],
            locations: [],
            type: "Лекція",
            week: .first,
            day: .monday,
            position: .second
        ),
        LessonResponse(
            names: ["Third Monday"],
            teachers: [],
            locations: [],
            type: "Лекція",
            week: .first,
            day: .monday,
            position: .third
        ),
        LessonResponse(
            names: ["Fourth Monday"],
            teachers: [],
            locations: [],
            type: "Лекція",
            week: .first,
            day: .monday,
            position: .fourth
        ),

        LessonResponse(
            names: ["First Tue"],
            teachers: [],
            locations: [],
            type: "Лекція",
            week: .first,
            day: .tuesday,
            position: .first
        ),
        LessonResponse(
            names: ["Third Tue"],
            teachers: [],
            locations: [],
            type: "Лекція",
            week: .first,
            day: .tuesday,
            position: .third
        ),
        LessonResponse(
            names: ["Fourth Tue"],
            teachers: [],
            locations: [],
            type: "Лекція",
            week: .first,
            day: .tuesday,
            position: .fourth
        ),

        LessonResponse(
            names: ["Second Wed"],
            teachers: [],
            locations: [],
            type: "Лекція",
            week: .first,
            day: .wednesday,
            position: .second
        ),
        LessonResponse(
            names: ["Third Wed"],
            teachers: [],
            locations: [],
            type: "Лекція",
            week: .first,
            day: .wednesday,
            position: .third
        ),
        LessonResponse(
            names: ["Fourth Wed"],
            teachers: [],
            locations: [],
            type: "Лекція",
            week: .first,
            day: .wednesday,
            position: .fourth
        ),
        LessonResponse(
            names: ["Ha ha"],
            teachers: [],
            locations: [],
            type: "Лекція",
            week: .second,
            day: .tuesday,
            position: .second
        )
    ]

}
