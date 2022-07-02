//
//  GroupRozkladSection.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.07.2022.
//

import Foundation
import IdentifiedCollections

// MARK: - Section

extension GroupRozklad.State {

    struct Section: Equatable, Identifiable {

        static func id(week: Lesson.Week, day: Lesson.Day) -> String {
            "\(Section.self)\(week.rawValue)\(day.rawValue)"
        }

        let position: Position
        var lessonCells: IdentifiedArrayOf<LessonCell.State>

        var id: String {
            Section.id(week: position.week, day: position.day)
        }

        var index: Int {
            position.index
        }
    }

}

// MARK: - Section.Position

extension GroupRozklad.State.Section {

    struct Position: Equatable, Identifiable {

        static var count: Int {
            Lesson.Week.allCases.count * Lesson.Day.allCases.count
        }

        static func index(week: Lesson.Week, day: Lesson.Day) -> Int {
            (week.rawValue - 1) * Lesson.Day.allCases.count + (day.rawValue - 1)
        }

        let week: Lesson.Week
        let day: Lesson.Day

        var id: Int {
            index
        }

        var index: Int {
            Position.index(week: week, day: day)
        }
    }

}

// MARK: - Section.Position init

extension GroupRozklad.State.Section.Position {

    init(index: Int) {
        switch index {
        case (0..<6):
            week = .first
            day = Lesson.Day(rawValue: index + 1) ?? .monday

        case (6..<12):
            week = .second
            day = Lesson.Day(rawValue: index - 5) ?? .monday

        default:
            assertionFailure("Invalid index")
            week = .first
            day = .monday
        }
    }

}

// MARK: - Array + GroupRozklad.State.Section

extension Array where Element == GroupRozklad.State.Section {

    static func combine<T, V>(_ firsts: [T], _ seconds: [V]) -> [(T, V)] {
        var result: [(T, V)] = []
        for first in firsts {
            for second in seconds {
                result.append((first, second))
            }
        }
        return result
    }

    init(
        lessons: IdentifiedArrayOf<Lesson>,
        currentLesson: CurrentLesson? = nil,
        nextLesson: Lesson.ID? = nil
    ) {
        let emptySections = Self.combine(Lesson.Week.allCases, Lesson.Day.allCases)
            .map {
                GroupRozklad.State.Section(
                    position: .init(week: $0, day: $1),
                    lessonCells: []
                )
            }
        self = lessons.reduce(into: emptySections) { partialResult, lesson in
            var mode: LessonMode = .default
            if lesson.id == currentLesson?.lessonId {
                mode = .current(currentLesson?.percent ?? 0)
            } else if lesson.id == nextLesson {
                mode = .next
            }
            let lessonState = LessonCell.State(
                lesson: lesson,
                mode: mode
            )
            partialResult[
                ScheduleDay.index(
                    week: lesson.week,
                    day: lesson.day
                )
            ].lessonCells.append(lessonState)
        }
    }

}
