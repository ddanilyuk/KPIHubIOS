//
//  Lesson.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.05.2022.
//

import Foundation

public struct LessonResponse: Equatable {
    // MARK: - Position
    
    public enum Position: Int, Codable, CaseIterable, Equatable {
        case first = 1
        case second
        case third
        case fourth
        case fifth
        case sixth
    }

    // MARK: - Day
    
    public enum Day: Int, Codable, CaseIterable, Equatable {
        case monday = 1
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }

    // MARK: - Week
    
    public enum Week: Int, Codable, Equatable, CaseIterable {
        case first = 1
        case second
    }

    public let names: [String]
    public let teachers: [String]?
    public let locations: [String]?
    public let type: String

    public let week: Week
    public let day: Day
    public let position: Position
}

// MARK: - Codable

extension LessonResponse: Codable { }

// MARK: - Hashable

extension LessonResponse: Hashable { }

// MARK: - Identifiable

extension LessonResponse: Identifiable {
    public var id: Int {
        hashValue
    }
}

// MARK: - Mock

extension LessonResponse {
    public static let mocked: [LessonResponse] = [
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
