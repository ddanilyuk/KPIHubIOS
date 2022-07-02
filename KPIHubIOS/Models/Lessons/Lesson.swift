//
//  Lesson.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import Foundation

struct Lesson {

    var names: [String]
    var teachers: [String]?
    var locations: [String]?
    var type: String

    var week: Week
    var day: Day
    var position: Position

    var links: [String]

    let lessonResponse: LessonResponse
}

// MARK: Lesson + LessonResponse

extension Lesson {

    init(lessonResponse: LessonResponse) {
        self.names = lessonResponse.names
        self.teachers = lessonResponse.teachers
        self.locations = lessonResponse.locations
        self.type = lessonResponse.type
        self.week = Week(lessonResponseWeek: lessonResponse.week)
        self.day = Day(lessonResponseDay: lessonResponse.day)
        self.position = Position(lessonResponsePosition: lessonResponse.position)

        self.links = []

        self.lessonResponse = lessonResponse
    }
    
}

// MARK: Positon

extension Lesson {

    enum Position: Int, Codable, CaseIterable, Equatable {
        case first = 1
        case second
        case third
        case fourth
        case fifth
        case sixth

        struct Description {
            let firstPartStart: String
            let firstPartEnd: String
            let secondPartStart: String
            let secondPartEnd: String
        }

        var description: Description {
            switch self {
            case .first:
                return Description(
                    firstPartStart: "8:30",
                    firstPartEnd: "9:15",
                    secondPartStart: "9:20",
                    secondPartEnd: "10:05"
                )
            case .second:
                return Description(
                    firstPartStart: "10:25",
                    firstPartEnd: "11:10",
                    secondPartStart: "11:15",
                    secondPartEnd: "12:00"
                )

            case .third:
                return Description(
                    firstPartStart: "12:20",
                    firstPartEnd: "13:05",
                    secondPartStart: "13:10",
                    secondPartEnd: "13:55"
                )

            case .fourth:
                return Description(
                    firstPartStart: "14:15",
                    firstPartEnd: "15:00",
                    secondPartStart: "15:05",
                    secondPartEnd: "15:50"
                )

            case .fifth:
                return Description(
                    firstPartStart: "16:10",
                    firstPartEnd: "16:55",
                    secondPartStart: "17:00",
                    secondPartEnd: "17:45"
                )

            case .sixth:
                return Description(
                    firstPartStart: "18:05",
                    firstPartEnd: "18:50",
                    secondPartStart: "18:55",
                    secondPartEnd: "19:40"
                )

            }
        }

        static var lessonDuration: Int = 95

        var minutesFromDayStart: Int {
            func calculate(hour: Int, minute: Int) -> Int {
                return hour * 60 + minute
            }
            switch self {
            case .first:
                return calculate(hour: 8, minute: 30)
            case .second:
                return calculate(hour: 10, minute: 25)
            case .third:
                return calculate(hour: 12, minute: 20)
            case .fourth:
                return calculate(hour: 14, minute: 15)
            case .fifth:
                return calculate(hour: 16, minute: 10)
            case .sixth:
                return calculate(hour: 18, minute: 05)

            }
        }

        var minutesFromDayStartEnd: Int {
            return minutesFromDayStart + Position.lessonDuration
        }

        var range: Range<Int> {
            return minutesFromDayStart..<minutesFromDayStart + Position.lessonDuration
        }

        init(lessonResponsePosition: LessonResponse.Position) {
            self = .init(rawValue: lessonResponsePosition.rawValue) ?? .first
        }
    }

}

// MARK: - Day

extension Lesson {

    enum Day: Int, Codable, CaseIterable, Equatable, Comparable {
        static func < (lhs: Lesson.Day, rhs: Lesson.Day) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        case monday = 1
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday

        init(lessonResponseDay: LessonResponse.Day) {
            self = .init(rawValue: lessonResponseDay.rawValue) ?? .monday
        }

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

}

// MARK: - Week

extension Lesson {

    enum Week: Int, Codable, Equatable, CaseIterable {
        case first = 1
        case second

        init(lessonResponseWeek: LessonResponse.Week) {
            self = .init(rawValue: lessonResponseWeek.rawValue) ?? .first
        }

        func toggled() -> Week {
            switch self {
            case .first:
                return .second
            case .second:
                return .first
            }
        }

        var description: String {
            switch self {
            case .first:
                return "1 тиждень"
            case .second:
                return "2 тиждень"
            }
        }
    }

}

// MARK: - Equatable

extension Lesson: Equatable {

}

// MARK: - Codable

extension Lesson: Codable {

}


// MARK: - Identifiable

extension Lesson: Identifiable {

    var id: LessonResponse.ID {
        return lessonResponse.id
    }
    
}


//extension Lesson {
//
//    var type: String {
//        let location = locations?.first ?? ""
//        switch location.lowercased() {
//        case let string where string.contains("лек"):
//            return "Лекція"
//
//        case let string where string.contains("прак"):
//            return "Практика"
//
//        case let string where string.contains("лаб"):
//            return "Лабораторна"
//
//        default:
//            return "Невідомо"
//        }
//    }
//
//}
