//
//  DateTimeClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 23.06.2022.
//

import Foundation
import Combine
import Dependencies
import Common

struct CurrentDateService {
    var updatedStream: () -> AsyncStream<Date>
    var currentLesson: () -> CurrentLesson?
    var nextLessonID: () -> Lesson.ID?
    var currentDay: () -> Lesson.Day?
    var currentWeek: () -> Lesson.Week
    var forceUpdate: () -> Void
}
