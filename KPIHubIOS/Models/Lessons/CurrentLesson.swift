//
//  CurrentLesson.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.06.2022.
//

import Foundation
import CoreGraphics

struct CurrentLesson: Equatable {
    var lessonId: Lesson.ID
    var percent: CGFloat
}
