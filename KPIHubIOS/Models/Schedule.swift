//
//  Schedule.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 31.05.2022.
//

import Foundation

struct Schedule: Equatable {

    var firstWeek: [ScheduleDay]
    var secondWeek: [ScheduleDay]

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

    init(lessons: [Lesson]) {
        self.firstWeek = Lesson.Day.allCases.map {
            ScheduleDay(week: .first, day: $0, lessons: [])
        }
        self.secondWeek = Lesson.Day.allCases.map {
            ScheduleDay(week: .second, day: $0, lessons: [])
        }

        for lesson in lessons {
            switch lesson.week {
            case .first:
                self.firstWeek[lesson.day.rawValue - 1].lessons.append(lesson)
            case .second:
                self.secondWeek[lesson.day.rawValue - 1].lessons.append(lesson)
            }
        }
    }
}
