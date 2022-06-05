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
    let teachers: [Teacher]?
    let locations: [String]?

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
                Teacher(
                    fullName: "асистент Каплунов Артем Володимирович",
                    shortName: "ас. Каплунов А. В."
                ),
                Teacher(
                    fullName: "доцент Долголенко Олександр Миколайович",
                    shortName: "доц. Долголенко О. М."
                )
            ],
            locations: [],
            week: .first,
            day: .monday,
            position: .first
        ),
        LessonResponse(
            names: ["Second Monday"],
            teachers: [],
            locations: [],
            week: .first,
            day: .monday,
            position: .second
        ),
        LessonResponse(
            names: ["Third Monday"],
            teachers: [],
            locations: [],
            week: .first,
            day: .monday,
            position: .third
        ),
        LessonResponse(
            names: ["Fourth Monday"],
            teachers: [],
            locations: [],
            week: .first,
            day: .monday,
            position: .fourth
        ),

        LessonResponse(
            names: ["First Tue"],
            teachers: [],
            locations: [],
            week: .first,
            day: .tuesday,
            position: .first
        ),
        LessonResponse(
            names: ["Third Tue"],
            teachers: [],
            locations: [],
            week: .first,
            day: .tuesday,
            position: .third
        ),
        LessonResponse(
            names: ["Fourth Tue"],
            teachers: [],
            locations: [],
            week: .first,
            day: .tuesday,
            position: .fourth
        ),

        LessonResponse(
            names: ["Second Wed"],
            teachers: [],
            locations: [],
            week: .first,
            day: .wednesday,
            position: .second
        ),
        LessonResponse(
            names: ["Third Wed"],
            teachers: [],
            locations: [],
            week: .first,
            day: .wednesday,
            position: .third
        ),
        LessonResponse(
            names: ["Fourth Wed"],
            teachers: [],
            locations: [],
            week: .first,
            day: .wednesday,
            position: .fourth
        ),
        LessonResponse(
            names: ["Ha ha"],
            teachers: [],
            locations: [],
            week: .second,
            day: .tuesday,
            position: .second
        )
    ]

}
