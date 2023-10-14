//
//  CurrentLesson.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.06.2022.
//

import Foundation
import CoreGraphics

public struct CurrentLesson: Equatable {
    public var lessonID: Lesson.ID
    public var percent: CGFloat
    
    public init(lessonID: Lesson.ID, percent: CGFloat) {
        self.lessonID = lessonID
        self.percent = percent
    }
}
