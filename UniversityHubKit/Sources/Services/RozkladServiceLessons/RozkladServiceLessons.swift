//
//  RozkladServiceLessons.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import IdentifiedCollections
import Combine

public struct RozkladServiceLessons {
    public var lessonsStream: () -> AsyncStream<IdentifiedArrayOf<Lesson>>
    public var currentLessons: () -> IdentifiedArrayOf<Lesson>
    
    public var updatedAtStream: () -> AsyncStream<Date?>
    public var currentUpdatedAt: () -> Date?

    public var set: (ClientValue<[Lesson]>) -> Void
    public var modify: (ClientValue<Lesson>) -> Void
    public var commit: () -> Void
}
