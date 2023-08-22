//
//  RozkladServiceLessons+Dependency.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Dependencies

extension DependencyValues {
    private enum RozkladServiceLessonsKey: TestDependencyKey {
        static let testValue = RozkladServiceLessons.mock()
        static let liveValue = RozkladServiceLessons.live()
    }
    
    var rozkladServiceLessons: RozkladServiceLessons {
        get { self[RozkladServiceLessonsKey.self] }
        set { self[RozkladServiceLessonsKey.self] = newValue }
    }
}
