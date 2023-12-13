//
//  CurrentDateService+Live.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import Dependencies
import Combine
import UIKit
import IdentifiedCollections

extension CurrentDateService {
    static func live() -> CurrentDateService {
        let helper = Helper()
        return CurrentDateService(
            updatedStream: { AsyncStream(helper.updatedSubject.values) },
            currentLesson: { helper.currentLessonSubject.value },
            nextLessonID: { helper.nextLessonIDSubject.value },
            currentDay: { helper.currentDaySubject.value },
            currentWeek: { helper.currentWeekSubject.value },
            forceUpdate: { helper.updateSubjects(with: Date()) }
        )
    }
}

private extension CurrentDateService {
    final class Helper {
        @Dependency(\.userDefaultsService) private var userDefaultsService
        @Dependency(\.rozkladServiceLessons) private var rozkladServiceLessons
        private var calendar = Calendar(identifier: .gregorian)
        private var timer: Timer?
        private var lessonsTask: Task<Void, Never>?
        private var notificationCenterTask: Task<Void, Never>?
        
        // swiftlint:disable private_subject
        let currentDaySubject = CurrentValueSubject<Lesson.Day?, Never>(nil)
        let currentWeekSubject = CurrentValueSubject<Lesson.Week, Never>(.first)
        let currentLessonSubject = CurrentValueSubject<CurrentLesson?, Never>(nil)
        let nextLessonIDSubject = CurrentValueSubject<Lesson.ID?, Never>(nil)
        let updatedSubject = CurrentValueSubject<Date, Never>(Date())
        // swiftlint:enable private_subject
        
        init() {
            calendar.timeZone = TimeZone(identifier: "Europe/Kiev")!
            updateSubjects(with: Date())
            setTimer()
            
            // Setup lesson changes update
            lessonsTask = Task {
                for await _ in rozkladServiceLessons.lessonsStream() {
                    updateSubjects(with: Date())
                }
            }
            
            notificationCenterTask = Task {
                let name = await UIApplication.didBecomeActiveNotification
                for await _ in NotificationCenter.default.notifications(named: name).dropFirst() {
                    setTimer()
                    updateSubjects(with: Date())
                }
            }
        }
        
        func updateSubjects(with date: Date) {
            let (dayNumber, weekNumber) = currentDayWeek(
                calendar: calendar,
                from: date,
                toggleWeek: userDefaultsService.get(for: .toggleWeek)
            )
            let currentDay = Lesson.Day(rawValue: dayNumber)
            let currentWeek = Lesson.Week(rawValue: weekNumber) ?? .first
            currentDaySubject.value = currentDay
            currentWeekSubject.value = currentWeek

            let currentLessons = rozkladServiceLessons.currentLessons()
            if !currentLessons.isEmpty {
                let (currentLesson, nextLesson) = currentAndNextLesson(
                    lessons: currentLessons,
                    currentTimeFromDayStart: currentTimeFromDayStart(calendar: calendar, date: date),
                    currentWeek: currentWeek,
                    currentDay: currentDay
                )
                currentLessonSubject.value = currentLesson
                nextLessonIDSubject.value = nextLesson.id
            }

            updatedSubject.send(Date())
        }

        func setTimer() {
            var components = calendar.dateComponents(
                [.era, .year, .month, .day, .hour, .minute],
                from: Date()
            )
            components.second = 0
            let min = components.minute ?? 0
            components.minute = min + 1
            let nextMinute = calendar.date(from: components) ?? Date()

            timer?.invalidate()
            // Setup timer update
            timer = Timer(fire: nextMinute, interval: 60, repeats: true) { _ in
                self.updateSubjects(with: Date())
            }
            RunLoop.main.add(timer!, forMode: .default)
        }
        
        private func currentDayWeek(
            calendar: Calendar,
            from date: Date,
            toggleWeek: Bool
        ) -> (dayNumber: Int, weekNumber: Int) {
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

        private func currentAndNextLesson(
            lessons: IdentifiedArrayOf<Lesson>,
            currentTimeFromDayStart: Int,
            currentWeek: Lesson.Week,
            currentDay: Lesson.Day?
        ) -> (current: CurrentLesson?, next: Lesson) {
            guard let currentDay else {
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
                            current: CurrentLesson(lessonID: lesson.id, percent: percent),
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

        private func currentTimeFromDayStart(calendar: Calendar, date: Date) -> Int {
            let components = calendar.dateComponents(
                [.hour, .minute],
                from: date
            )
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            return hour * 60 + minute
        }
    }
}
