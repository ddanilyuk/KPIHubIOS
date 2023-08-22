//
//  DateTimeClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 23.06.2022.
//

import Foundation
import Combine
import Dependencies

struct CurrentDateService {
    let currentLesson: CurrentValueSubject<CurrentLesson?, Never>
    let nextLessonID: CurrentValueSubject<Lesson.ID?, Never>
    let currentDay: CurrentValueSubject<Lesson.Day?, Never>
    let currentWeek: CurrentValueSubject<Lesson.Week, Never>

    let forceUpdate: () -> Void
    var updated: AnyPublisher<Date, Never> { updatedSubject.eraseToAnyPublisher() }
    private let updatedSubject: CurrentValueSubject<Date, Never>

    init(
        currentLesson: CurrentValueSubject<CurrentLesson?, Never>,
        nextLessonID: CurrentValueSubject<Lesson.ID?, Never>,
        currentDay: CurrentValueSubject<Lesson.Day?, Never>,
        currentWeek: CurrentValueSubject<Lesson.Week, Never>,
        forceUpdate: @escaping () -> Void,
        updatedSubject: CurrentValueSubject<Date, Never>
    ) {
        self.currentLesson = currentLesson
        self.nextLessonID = nextLessonID
        self.currentDay = currentDay
        self.currentWeek = currentWeek
        self.forceUpdate = forceUpdate
        self.updatedSubject = updatedSubject
    }
}
