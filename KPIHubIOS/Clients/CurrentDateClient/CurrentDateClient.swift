//
//  DateTimeClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 23.06.2022.
//

import Foundation
import Combine
import IdentifiedCollections
import CoreGraphics
import UIKit

let date = Date(timeIntervalSince1970: 1655893226)

struct CurrentLesson: Equatable {
    var lessonId: Lesson.ID
    var percent: CGFloat
}

struct CurrentDateClient {

    var currentLessonId: CurrentValueSubject<CurrentLesson?, Never>
    var nextLessonId: CurrentValueSubject<Lesson.ID?, Never>

    var currentDay: CurrentValueSubject<Lesson.Day?, Never>
    var currentWeek: CurrentValueSubject<Lesson.Week, Never>

    var updated: AnyPublisher<Void, Never> {
        updatedSubject.eraseToAnyPublisher()
    }
    var updatedSubject: CurrentValueSubject<Void, Never>

    static var liveCancellables: Set<AnyCancellable> = []

    // swiftlint:disable function_body_length
    static func live(rozkladClient: RozkladClientable) -> CurrentDateClient {

        func currentDayWeek(from date: Date) -> (dayNumber: Int, weekNumber: Int) {
            let components = calendar.dateComponents(
                [.weekOfYear, .weekday],
                from: date
            )
            var weekOfYear = components.weekOfYear ?? 0
            var dayNumber = components.weekday! - 1
            if dayNumber == 0 {
                dayNumber = 7
            }
            if toggleWeek {
                weekOfYear += 1
            }
            let weekNumber = weekOfYear % 2 + 1
            return (dayNumber: dayNumber, weekNumber: weekNumber)
        }

        func currentAndNextLesson(
            lessons: IdentifiedArrayOf<Lesson>,
            currentTimeFromDayStart: Int,
            currentWeek: Lesson.Week,
            currentDay: Lesson.Day?
        ) -> (current: CurrentLesson?, next: Lesson) {

            guard let currentDay = currentDay else {
                return (
                    current: nil,
                    next: lessons.first(where: { $0.week == currentWeek.toggled() }) ?? lessons[0]
                )
            }

            for lesson in lessons {
                guard lesson.week == currentWeek else {
                    continue
                }
                switch lesson.day {
                case currentDay:
                    switch lesson.position {
                    case let position where position.range.contains(currentTimeFromDayStart):
                        let difference = CGFloat(currentTimeFromDayStart - position.minutesFromDayStart)
                        let percent = difference / CGFloat(Lesson.Position.lessonDuration)
                        return (
                            current: CurrentLesson(lessonId: lesson.id, percent: percent),
                            next: lessons[safe: lessons.index(id: lesson.id)! + 1] ?? lessons[0]
                        )

                    case let position where position.minutesFromDayStartEnd > currentTimeFromDayStart:
                        return (current: nil, next: lesson)

                    default:
                        continue
                    }

                case let lessonDay where lessonDay > currentDay:
                    return (current: nil, next: lesson)

                default:
                    continue
                }
            }
            return (current: nil, next: lessons[0])
        }

        func currentTimeFromDayStart(calendar: Calendar, date: Date) -> Int {
            let components = calendar.dateComponents(
                [.hour, .minute],
                from: date
            )
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            return hour * 60 + minute
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Kiev")!

        let (dayNumber, weekNumber) = currentDayWeek(from: Date())
        let currentDay = Lesson.Day(rawValue: dayNumber)
        let currentWeek = Lesson.Week(rawValue: weekNumber) ?? .first
        let currentDaySubject = CurrentValueSubject<Lesson.Day?, Never>(currentDay)
        let currentWeekSubject = CurrentValueSubject<Lesson.Week, Never>(currentWeek)

        let currentLessonIdSubject = CurrentValueSubject<CurrentLesson?, Never>(nil)
        let nextLessonIdSubject = CurrentValueSubject<Lesson.ID?, Never>(nil)

        if !rozkladClient.lessons.subject.value.isEmpty {
            let (currentLesson, nextLesson) = currentAndNextLesson(
                lessons: rozkladClient.lessons.subject.value,
                currentTimeFromDayStart: currentTimeFromDayStart(calendar: calendar, date: date),
                currentWeek: currentWeek,
                currentDay: currentDay
            )
            currentLessonIdSubject.value = currentLesson
            nextLessonIdSubject.value = nextLesson.id
        }

        let updatedSubject = CurrentValueSubject<Void, Never>(())

        func updateSubjects(with date: Date) {
            print("Updating date subjects")
            let (dayNumber, weekNumber) = currentDayWeek(from: date)
            let currentDay = Lesson.Day(rawValue: dayNumber)
            let currentWeek = Lesson.Week(rawValue: weekNumber) ?? .first
            currentDaySubject.value = currentDay
            currentWeekSubject.value = currentWeek

            if !rozkladClient.lessons.subject.value.isEmpty {
                let (currentLesson, nextLesson) = currentAndNextLesson(
                    lessons: rozkladClient.lessons.subject.value,
                    currentTimeFromDayStart: currentTimeFromDayStart(calendar: calendar, date: date),
                    currentWeek: currentWeek,
                    currentDay: currentDay
                )
                currentLessonIdSubject.value = currentLesson
                nextLessonIdSubject.value = nextLesson.id
            }

            updatedSubject.send()
        }

        var components = calendar.dateComponents([.era, .year, .month, .day, .hour, .minute], from: date)
        components.second = 0
        let min = components.minute ?? 0
        components.minute = min + 1
        let nextMinute = calendar.date(from: components) ?? Date()

        // Setup timer
        let timer = Timer(fire: nextMinute, interval: 60, repeats: true) { _ in
            updateSubjects(with: Date())
        }
        RunLoop.main.add(timer, forMode: .default)

        rozkladClient.lessons.subject.eraseToAnyPublisher()
            .sink { _ in
                updateSubjects(with: Date())
            }
            .store(in: &liveCancellables)
        
        // Setup notification on change clock
        NotificationCenter.default
            .publisher(for: NSNotification.Name.NSSystemClockDidChange)
            .sink(receiveValue: { _ in
                updateSubjects(with: Date())
            })
            .store(in: &liveCancellables)

        return .init(
            currentLessonId: currentLessonIdSubject,
            nextLessonId: nextLessonIdSubject,
            currentDay: currentDaySubject,
            currentWeek: currentWeekSubject,
            updatedSubject: updatedSubject
        )
    }

    static func mock() -> CurrentDateClient {

        let currentDaySubject = CurrentValueSubject<Lesson.Day?, Never>(.monday)
        let currentWeekSubject = CurrentValueSubject<Lesson.Week, Never>(.first)
        let currentLessonIdSubject = CurrentValueSubject<CurrentLesson?, Never>(nil)
        let nextLessonIdSubject = CurrentValueSubject<Lesson.ID?, Never>(nil)
        let updatedSubject = CurrentValueSubject<Void, Never>(())

        return .init(
            currentLessonId: currentLessonIdSubject,
            nextLessonId: nextLessonIdSubject,
            currentDay: currentDaySubject,
            currentWeek: currentWeekSubject,
            updatedSubject: updatedSubject
        )
    }
}
