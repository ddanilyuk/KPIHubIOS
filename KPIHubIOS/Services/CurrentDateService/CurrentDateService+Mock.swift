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
        CurrentDateService(
            updatedStream: { .never },
            currentLesson: { nil },
            nextLessonID: { nil },
            currentDay: { .monday },
            currentWeek: { .first },
            forceUpdate: { }
        )
    }
}
