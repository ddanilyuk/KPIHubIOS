//
//  DateTimeClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 23.06.2022.
//

import Foundation
import Combine
import DependenciesMacros

@DependencyClient
public struct CurrentDateService {
    public struct CurrentLesson: Equatable {
        public var lessonID: Int
        public var percent: Double
        
        public init(lessonID: Int, percent: Double) {
            self.lessonID = lessonID
            self.percent = percent
        }
    }
    
    public var updatedStream: () -> AsyncStream<Date> = { .never }
    public var currentLesson: () -> CurrentLesson?
    public var nextLessonID: () -> Int?
    public var currentDay: () -> Int?
    public var currentWeek: () -> Int = { 1 }
    public var forceUpdate: () -> Void
}
