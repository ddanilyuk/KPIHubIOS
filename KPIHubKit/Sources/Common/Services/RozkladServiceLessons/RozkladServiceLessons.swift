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
    var lessonsStream: () -> AsyncStream<IdentifiedArrayOf<Lesson>>
    var currentLessons: () -> IdentifiedArrayOf<Lesson>
    
    var updatedAtStream: () -> AsyncStream<Date?>
    var currentUpdatedAt: () -> Date?

    var set: (ClientValue<[Lesson]>) -> Void
    var modify: (ClientValue<Lesson>) -> Void
    var commit: () -> Void
}
