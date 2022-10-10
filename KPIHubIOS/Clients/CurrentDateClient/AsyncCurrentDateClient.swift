//
//  AsyncCurrentDateClientV2.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 09.10.2022.
//

import Foundation
import Combine
import IdentifiedCollections
import UIKit
import ComposableArchitecture
import Asynchrone

struct AsyncCurrentDateClient {

//    let some = CombineAsyncStream
//    let currentLesson: AnyAsyncSequenceable<CurrentLesson?>
//    let nextLessonID: AnyAsyncSequenceable<Lesson.ID?>
//    let currentDay: AnyAsyncSequenceable<Lesson.Day?>
//    let currentWeek: AnyAsyncSequenceable<Lesson.Week>
//
//    let forceUpdate: () -> Void
    var updated: AsyncStream<Value>

}

// MARK: - Live

extension AsyncCurrentDateClient {
    
    final class Box<Wrapped> {
      var wrappedValue: Wrapped

      init(wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
      }

      var boxedValue: Wrapped {
        _read { yield self.wrappedValue }
        _modify { yield &self.wrappedValue }
      }
    }
    
    
    
    /*
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
     */

    struct Value: Equatable {
        var currentDay: Lesson.Day?
        var currentWeek: Lesson.Week?
        var currentLesson: CurrentLesson?
        var nextLessonID: Lesson.ID?
    }

    // swiftlint:disable function_body_length
    static func live(
        userDefaultsClient: UserDefaultsClientable,
        rozkladClientLessons: RozkladClientLessons
    ) -> Self {
        let calendar: Calendar = {
            var calendar = Calendar(identifier: .gregorian)
            calendar.timeZone = TimeZone(identifier: "Europe/Kiev")!
            return calendar
        }()

        var timer: Timer?
        var currentDaySubject: Box<Lesson.Day?> = .init(wrappedValue: nil)
        var currentWeekSubject: Box<Lesson.Week?> = .init(wrappedValue: nil)
        var currentLessonSubject: Box<CurrentLesson?> = .init(wrappedValue: nil)
        var nextLessonIDSubject: Box<Lesson.ID?> = .init(wrappedValue: nil)
        
        let (continuation, asyncSequence) = AsyncStream<Value>.pipe()
        
        setTimer(for: &timer, calendar: calendar) {
            updateSubjects(with: Date())
        }
        
        withUnsafeContinuation<Void.self> { _ in
            for try await _ in rozkladClientLessons.subject.asyncStream() {
                updateSubjects(with: Date())
            }
        }

//        rozkladClientLessons.subject.eraseToAnyPublisher()
//            .dropFirst()
//            .handleEvents(
//                receiveOutput: {
//
//                }
//            )
//            .sink { _ in
//                updateSubjects(with: Date())
//            }
//            .store(in: &liveCancellables)

        // Setup notification on becomeActive
//        NotificationCenter.default
//            .publisher(for: UIApplication.didBecomeActiveNotification)
//            .dropFirst()
//            .sink { _ in
//                // Invalidate time and create new
//                // Because user can change time
//                setTimer()
//                updateSubjects(with: Date())
//            }
//            .store(in: &liveCancellables)

        func updateSubjects(with date: Date) {
            let (dayNumber, weekNumber) = currentDayWeek(
                calendar: calendar,
                from: date,
                toggleWeek: userDefaultsClient.get(for: .toggleWeek)
            )
            let currentDay = Lesson.Day(rawValue: dayNumber)
            let currentWeek = Lesson.Week(rawValue: weekNumber) ?? .first
            currentDaySubject.boxedValue = currentDay
            currentWeekSubject.boxedValue = currentWeek

            if !rozkladClientLessons.subject.value.isEmpty {
                let (currentLesson, nextLesson) = currentAndNextLesson(
                    lessons: rozkladClientLessons.subject.value,
                    currentTimeFromDayStart: currentTimeFromDayStart(calendar: calendar, date: date),
                    currentWeek: currentWeek,
                    currentDay: currentDay
                )
                currentLessonSubject.boxedValue = currentLesson
                nextLessonIDSubject.boxedValue = nextLesson.id
            }

            continuation.yield(
                Value(
                    currentDay: currentDaySubject.boxedValue,
                    currentWeek: currentWeekSubject.boxedValue,
                    currentLesson: currentLessonSubject.boxedValue,
                    nextLessonID: nextLessonIDSubject.boxedValue
                )
            )
        }
        
        return AsyncCurrentDateClient(
            updated: asyncSequence
        )
    }
    
    private static func setTimer(
        for timer: inout Timer?,
        calendar: Calendar,
        onFire: @escaping () -> Void
    ) {
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
            onFire()
        }
        RunLoop.main.add(timer!, forMode: .default)
    }

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

enum AsyncCurrentDateClientKey: DependencyKey {
    static let liveValue = AsyncCurrentDateClient.live(
        userDefaultsClient: DependencyValues._current.userDefaultsClient,
        rozkladClientLessons: DependencyValues._current.rozkladClientLessons
    )
}

extension DependencyValues {
    var asyncCurrentDateClient: AsyncCurrentDateClient {
        get { self[AsyncCurrentDateClientKey.self] }
        set { self[AsyncCurrentDateClientKey.self] = newValue }
    }
}
