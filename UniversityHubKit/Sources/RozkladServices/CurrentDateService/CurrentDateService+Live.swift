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
import Extensions
import RozkladModels

extension CurrentDateService {
    static func live() -> CurrentDateService {
        let helper = LiveHelper()
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
    final class LiveHelper {
        @Dependency(\.userDefaultsService) private var userDefaultsService
        @Dependency(\.rozkladServiceLessons) private var rozkladServiceLessons
        @Dependency(\.date) private var date

        private var calendar = Calendar(identifier: .gregorian)
        private var timer: Timer?
        private var lessonsTask: Task<Void, Never>?
        private var notificationCenterTask: Task<Void, Never>?
        
        // swiftlint:disable private_subject
        let currentDaySubject = CurrentValueSubject<Int?, Never>(nil)
        let currentWeekSubject = CurrentValueSubject<Int, Never>(1)
        let currentLessonSubject = CurrentValueSubject<CurrentLesson?, Never>(nil)
        let nextLessonIDSubject = CurrentValueSubject<Int?, Never>(nil)
        let updatedSubject = CurrentValueSubject<Date, Never>(Date())
        // swiftlint:enable private_subject
        
        init() {
            calendar.timeZone = TimeZone(identifier: "Europe/Kiev")!
            updateSubjects(with: date())
            setTimer()
            
            // Setup lesson changes update
            lessonsTask = Task {
                for await _ in rozkladServiceLessons.lessonsStream() {
                    updateSubjects(with: date())
                }
            }
            
            notificationCenterTask = Task {
                let name = await UIApplication.didBecomeActiveNotification
                for await _ in NotificationCenter.default.notifications(named: name).dropFirst() {
                    setTimer()
                    updateSubjects(with: date())
                }
            }
        }
        
        func updateSubjects(with date: Date) {
            let (dayNumber, weekNumber) = currentDayWeek(
                calendar: calendar,
                from: date,
                toggleWeek: userDefaultsService.get(for: .toggleWeek)
            )
            currentDaySubject.value = dayNumber
            currentWeekSubject.value = weekNumber

            let currentLessons = rozkladServiceLessons.currentLessons()
            if !currentLessons.isEmpty {
                let currentTimeFromDayStart = currentTimeFromDayStart(calendar: calendar, date: date)
                let (currentLesson, nextLesson) = currentAndNextLesson(
                    lessons: currentLessons,
                    currentTimeFromDayStart: currentTimeFromDayStart,
                    currentWeek: weekNumber,
                    currentDay: dayNumber
                )
                currentLessonSubject.value = currentLesson
                nextLessonIDSubject.value = nextLesson
            }

            updatedSubject.send(self.date())
        }

        func setTimer() {
            var components = calendar.dateComponents(
                [.era, .year, .month, .day, .hour, .minute],
                from: date()
            )
            components.second = 0
            let min = components.minute ?? 0
            components.minute = min + 1
            let nextMinute = calendar.date(from: components) ?? date()

            timer?.invalidate()
            // Setup timer update
            timer = Timer(fire: nextMinute, interval: 60, repeats: true) { _ in
                self.updateSubjects(with: self.date())
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
            lessons: IdentifiedArrayOf<RozkladLessonModel>,
            currentTimeFromDayStart: Int,
            currentWeek: Int,
            currentDay: Int?
        ) -> (current: CurrentLesson?, next: Int) {
            guard let currentDay else {
                let next = lessons.first { $0.week != currentWeek }
                return (current: nil, next: next?.id ?? lessons[0].id)
            }

            for lesson in lessons {
                guard lesson.week == currentWeek else {
                    continue
                }
                switch lesson.day {
                case currentDay:
                    switch lesson.position {
                    case let position where position.range.contains(currentTimeFromDayStart):
                        let timePassed = currentTimeFromDayStart - position.start.minutesFromDayStart
                        let lessonDuration = position.end.minutesFromDayStart - position.start.minutesFromDayStart
                        let percent = Double(timePassed) / Double(lessonDuration)
                        return (
                            current: CurrentLesson(lessonID: lesson.id, percent: percent),
                            next: lessons[safe: lessons.index(id: lesson.id)! + 1]?.id ?? lessons[0].id
                        )
                        
                    case let position where position.start.minutesFromDayStart > currentTimeFromDayStart:
                        return (current: nil, next: lesson.id)

                    default:
                        continue
                    }

                case let lessonDay where lessonDay > currentDay:
                    return (current: nil, next: lesson.id)

                default:
                    continue
                }
            }
            return (current: nil, next: lessons[0].id)
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
