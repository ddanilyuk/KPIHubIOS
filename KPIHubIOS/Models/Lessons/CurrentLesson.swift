//
//  CurrentLesson.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.06.2022.
//

import Foundation
import CoreGraphics

struct CurrentLesson: Equatable {
    var lessonID: Lesson.ID
    var percent: CGFloat
}
