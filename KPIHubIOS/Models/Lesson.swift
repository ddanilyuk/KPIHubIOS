//
//  Lesson.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.05.2022.
//

import Foundation

struct Teacher: Equatable {
    var fullName: String
    var shortName: String
}

// MARK: - Codable

extension Teacher: Codable {

}

extension Teacher: Hashable {

}

struct NewLesson {

    let coreLesson: Lesson
}

struct Lesson: Equatable {

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

        var shortDescription: String {
            switch self {
            case .monday:
                return "ПН"
            case .tuesday:
                return "ВТ"
            case .wednesday:
                return "СР"
            case .thursday:
                return "ЧТ"
            case .friday:
                return "ПТ"
            case .saturday:
                return "СБ"
            }
        }

        var fullDescription: String {
            switch self {
            case .monday:
                return "Понеділок"
            case .tuesday:
                return "Вівторок"
            case .wednesday:
                return "Середа"
            case .thursday:
                return "Четвер"
            case .friday:
                return "П'ятниця"
            case .saturday:
                return "Субота"
            }
        }
    }

    // MARK: - Week

    enum Week: Int, Codable, Equatable, CaseIterable {
        case first = 1
        case second

        var description: String {
            switch self {
            case .first:
                return "1 тиждень"
            case .second:
                return "2 тиждень"
            }
        }
    }

    let names: [String]
    let teachers: [Teacher]?
    let locations: [String]?

    let position: Position
    let day: Day
    let week: Week

}

// MARK: - Codable

extension Lesson: Codable {

}

// MARK: - Identifiable

extension Lesson: Identifiable {

    var id: String {
        "\(week.rawValue)\(day.rawValue)\(position.rawValue)"
    }
}

