//
//  CurrentDateService+Mock.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import Combine

extension CurrentDateService {
    static func mock() -> CurrentDateService {
        let currentDaySubject = CurrentValueSubject<Lesson.Day?, Never>(.monday)
        let currentWeekSubject = CurrentValueSubject<Lesson.Week, Never>(.first)
        let currentLessonIDSubject = CurrentValueSubject<CurrentLesson?, Never>(nil)
        let nextLessonIDSubject = CurrentValueSubject<Lesson.ID?, Never>(nil)
        let updatedSubject = CurrentValueSubject<Date, Never>(Date())

        return CurrentDateService(
            currentLesson: currentLessonIDSubject,
            nextLessonID: nextLessonIDSubject,
            currentDay: currentDaySubject,
            currentWeek: currentWeekSubject,
            forceUpdate: { },
            updatedSubject: updatedSubject
        )
    }
}
