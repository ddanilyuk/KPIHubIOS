//
//  RozkladServiceLessons.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import IdentifiedCollections
import Combine

struct RozkladServiceLessons {
    let subject: CurrentValueSubject<IdentifiedArrayOf<Lesson>, Never>
    let updatedAtSubject: CurrentValueSubject<Date?, Never>

    let set: (ClientValue<[Lesson]>) -> Void
    let modify: (ClientValue<Lesson>) -> Void
    let commit: () -> Void
}
