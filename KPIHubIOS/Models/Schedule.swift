//
//  Schedule.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 31.05.2022.
//

import Foundation

struct ScheduleDay: Identifiable, Equatable, Hashable {
    let week: Lesson.Week
    let day: Lesson.Day
    var lessons: [Lesson]

    var id: String {
        ScheduleDay.id(week: week, day: day)
    }

    static func id(week: Lesson.Week, day: Lesson.Day) -> String {
        "\(ScheduleDay.self)\(week.rawValue)\(day.rawValue)"
    }

    static func index(week: Lesson.Week, day: Lesson.Day) -> Int {
        (week.rawValue - 1) * 6 + (day.rawValue - 1)
    }

    var index: Int {
        return (week.rawValue - 1) * 6 + (day.rawValue - 1)
    }

    //        static func == (lhs: ScheduleDay, rhs: ScheduleDay) {
    //            return lhs.id == rhs.id
    //        }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Array + ScheduleDay

extension Array where Element == ScheduleDay {

    static func combine<T, V>(_ firsts: [T], _ seconds: [V]) -> [(T, V)] {
        var result: [(T, V)] = []
        for first in firsts {
            for second in seconds {
                result.append((first, second))
            }
        }
        return result
    }

    init(lessons: [Lesson]) {
        let emptyScheduleDays = Array.combine(
            Lesson.Week.allCases,
            Lesson.Day.allCases
        ).map { ScheduleDay(week: $0, day: $1, lessons: []) }
        self = lessons.reduce(into: emptyScheduleDays) { partialResult, lesson in
            partialResult[ScheduleDay.index(week: lesson.week, day: lesson.day)].lessons.append(lesson)
        }
    }
}
