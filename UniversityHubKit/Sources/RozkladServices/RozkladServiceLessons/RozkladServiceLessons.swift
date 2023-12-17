//
//  RozkladServiceLessons.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import IdentifiedCollections
import DependenciesMacros
import RozkladModels
import Services

@DependencyClient
public struct RozkladServiceLessons {
    public var lessonsStream: () -> AsyncStream<IdentifiedArrayOf<RozkladLessonModel>> = { .never }
    public var currentLessons: () -> IdentifiedArrayOf<RozkladLessonModel> = { [] }
    
    public var updatedAtStream: () -> AsyncStream<Date?> = { .never }
    public var currentUpdatedAt: () -> Date?
    
    public var set: (ClientValue<[RozkladLessonModel]>) -> Void
    public var modify: (ClientValue<RozkladLessonModel>) -> Void
    public var commit: () -> Void
    
    public var getLessons: (_ groupID: UUID) async throws -> [RozkladLessonModel]
}
