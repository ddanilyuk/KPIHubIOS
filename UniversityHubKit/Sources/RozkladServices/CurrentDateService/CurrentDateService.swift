//
//  DateTimeClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 23.06.2022.
//

import Foundation
import Combine
import Dependencies
import Services

public struct CurrentDateService {
    public var updatedStream: () -> AsyncStream<Date>
    public var currentLesson: () -> CurrentLesson?
    public var nextLessonID: () -> Lesson.ID?
    public var currentDay: () -> Lesson.Day?
    public var currentWeek: () -> Lesson.Week
    public var forceUpdate: () -> Void
}
