//
//  DateTimeClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 23.06.2022.
//

import Foundation
import Combine
import IdentifiedCollections
import UIKit
import ComposableArchitecture

private enum CurrentDateClientKey: TestDependencyKey {
    static let testValue = CurrentDateClient.mock()
}

extension CurrentDateClientKey: DependencyKey {
    static let liveValue = CurrentDateClient.live(
        userDefaultsClient: DependencyValues._current.userDefaultsClient,
        rozkladClientLessons: DependencyValues._current.rozkladClientLessons
    )
}

extension DependencyValues {
    var currentDateClient: CurrentDateClient {
        get { self[CurrentDateClientKey.self] }
        set { self[CurrentDateClientKey.self] = newValue }
    }
}

struct CurrentDateClient {

    let currentLesson: CurrentValueSubject<CurrentLesson?, Never>
    let nextLessonID: CurrentValueSubject<Lesson.ID?, Never>
    let currentDay: CurrentValueSubject<Lesson.Day?, Never>
    let currentWeek: CurrentValueSubject<Lesson.Week, Never>

    let forceUpdate: () -> Void
    var updated: AnyPublisher<Date, Never> { updatedSubject.eraseToAnyPublisher() }
    private let updatedSubject: CurrentValueSubject<Date, Never>

}

// MARK: - Live

extension CurrentDateClient {

    // swiftlint:disable function_body_length
    static func live(
        userDefaultsClient: UserDefaultsClientable,
        rozkladClientLessons: RozkladClientLessons
    ) -> Self {

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Kiev")!

        let currentDaySubject = CurrentValueSubject<Lesson.Day?, Never>(nil)
        let currentWeekSubject = CurrentValueSubject<Lesson.Week, Never>(.first)
        let currentLessonSubject = CurrentValueSubject<CurrentLesson?, Never>(nil)
        let nextLessonIDSubject = CurrentValueSubject<Lesson.ID?, Never>(nil)
        let updatedSubject = CurrentValueSubject<Date, Never>(Date())

        var timer: Timer?

        updateSubjects(with: Date())
        setTimer()

        // Setup lesson changes update
        rozkladClientLessons.subject.eraseToAnyPublisher()
            .dropFirst()
            .sink { _ in
                updateSubjects(with: Date())
            }
            .store(in: &liveCancellables)

        // Setup notification on becomeActive
        NotificationCenter.default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .dropFirst()
            .sink { _ in
                // Invalidate time and create new
                // Because user can change time
                setTimer()
                updateSubjects(with: Date())
            }
            .store(in: &liveCancellables)

        func updateSubjects(with date: Date) {
            let (dayNumber, weekNumber) = currentDayWeek(
                calendar: calendar,
                from: date,
                toggleWeek: userDefaultsClient.get(for: .toggleWeek)
            )
            let currentDay = Lesson.Day(rawValue: dayNumber)
            let currentWeek = Lesson.Week(rawValue: weekNumber) ?? .first
            currentDaySubject.value = currentDay
            currentWeekSubject.value = currentWeek

            if !rozkladClientLessons.subject.value.isEmpty {
                let (currentLesson, nextLesson) = currentAndNextLesson(
                    lessons: rozkladClientLessons.subject.value,
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
                updateSubjects(with: Date())
            }
            RunLoop.main.add(timer!, forMode: .default)
        }

        return .init(
            currentLesson: currentLessonSubject,
            nextLessonID: nextLessonIDSubject,
            currentDay: currentDaySubject,
            currentWeek: currentWeekSubject,
            forceUpdate: { updateSubjects(with: Date()) },
            updatedSubject: updatedSubject
        )
    }

    private static var liveCancellables: Set<AnyCancellable> = []

    private static func currentDayWeek(
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

    private static func currentAndNextLesson(
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

    private static func currentTimeFromDayStart(calendar: Calendar, date: Date) -> Int {
        let components = calendar.dateComponents(
            [.hour, .minute],
            from: date
        )
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return hour * 60 + minute
    }

}

// MARK: - Mock

extension CurrentDateClient {

    static func mock() -> CurrentDateClient {
        let currentDaySubject = CurrentValueSubject<Lesson.Day?, Never>(.monday)
        let currentWeekSubject = CurrentValueSubject<Lesson.Week, Never>(.first)
        let currentLessonIDSubject = CurrentValueSubject<CurrentLesson?, Never>(nil)
        let nextLessonIDSubject = CurrentValueSubject<Lesson.ID?, Never>(nil)
        let updatedSubject = CurrentValueSubject<Date, Never>(Date())

        return .init(
            currentLesson: currentLessonIDSubject,
            nextLessonID: nextLessonIDSubject,
            currentDay: currentDaySubject,
            currentWeek: currentWeekSubject,
            forceUpdate: { },
            updatedSubject: updatedSubject
        )
    }

}
