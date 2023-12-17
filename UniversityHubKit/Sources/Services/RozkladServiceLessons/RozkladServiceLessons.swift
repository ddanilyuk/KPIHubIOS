//
//  RozkladServiceLessons.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import IdentifiedCollections
import DependenciesMacros

@DependencyClient
public struct RozkladServiceLessons {
    public var lessonsStream: () -> AsyncStream<IdentifiedArrayOf<Lesson>> = { .never }
    public var currentLessons: () -> IdentifiedArrayOf<Lesson> = { [] }
    
    public var updatedAtStream: () -> AsyncStream<Date?> = { .never }
    public var currentUpdatedAt: () -> Date?
    
    public var set: (ClientValue<[Lesson]>) -> Void
    public var modify: (ClientValue<Lesson>) -> Void
    public var commit: () -> Void
    
    public var getLessons: (_ group: GroupResponse) async throws -> [Lesson]
}
