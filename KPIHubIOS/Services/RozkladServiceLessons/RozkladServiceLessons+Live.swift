//
//  RozkladServiceLessons+Live.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import Combine
import Dependencies
import IdentifiedCollections

extension RozkladServiceLessons {
    static func live() -> RozkladServiceLessons {
        @Dependency(\.userDefaultsService) var userDefaultsService
        let subject = CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never>([])
        let updatedAtSubject = CurrentValueSubject<Date?, Never>(nil)

        let commit: () -> Void = {
            subject.value = userDefaultsService.get(for: .lessons) ?? []
            updatedAtSubject.value = userDefaultsService.get(for: .lessonsUpdatedAt)
        }
        commit()
        
        return RozkladServiceLessons(
            subject: subject,
            updatedAtSubject: updatedAtSubject,
            set: { clientValue in
                userDefaultsService.set(IdentifiedArray(uniqueElements: clientValue.value), for: .lessons)
                userDefaultsService.set(Date(), for: .lessonsUpdatedAt)
                if clientValue.commitChanges {
                    commit()
                }
            },
            modify: { clientValue in
                var lessons = IdentifiedArray(uniqueElements: userDefaultsService.get(for: .lessons) ?? [])
                let modifiedLesson = clientValue.value
                lessons[id: modifiedLesson.id] = modifiedLesson
                userDefaultsService.set(lessons, for: .lessons)
                if clientValue.commitChanges {
                    commit()
                }
            },
            commit: commit
        )
    }
}
