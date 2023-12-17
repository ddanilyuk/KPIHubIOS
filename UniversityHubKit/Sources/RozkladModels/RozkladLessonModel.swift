//
//  RozkladLessonModel.swift
//
//
//  Created by Denys Danyliuk on 16.12.2023.
//

import Services

public struct RozkladLessonModel: Identifiable, Equatable {
    public let id: Int
    public var names: [String]
    public var teachers: [String]?
    public var locations: [String]?
    public var type: String
    public var day: Int
    public var week: Int

    public init(lesson: Lesson) {
        self.id = lesson.id
        self.names = lesson.names
        self.teachers = lesson.teachers
        self.locations = lesson.locations
        self.type = lesson.type
        self.day = lesson.day.rawValue
        self.week = lesson.week.rawValue
    }
}

extension RozkladLessonModel: Codable { }

public enum RozkladLessonMode: Equatable {
    case current(Double)
    case next
    case `default`
    
    public var isCurrent: Bool {
        switch self {
        case .current:
            return true

        case .next, .default:
            return false
        }
    }
    
    public var percent: Double {
        switch self {
        case let .current(value):
            return value

        case .default:
            return 0

        case .next:
            return 0
        }
    }
}

public struct LessonDay: Equatable, Hashable {
    public let day: Int
    public let week: Int
    
    public var debugDescription: String {
        "Week: \(week) | Day: \(day)"
    }
    
    public init(day: Int, week: Int) {
        self.day = day
        self.week = week
    }
}
