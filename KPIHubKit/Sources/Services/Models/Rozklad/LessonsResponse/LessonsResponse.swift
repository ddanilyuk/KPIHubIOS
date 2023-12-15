//
//  LessonsResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.05.2022.
//

import Foundation

public struct LessonsResponse {
    public let id: UUID
    public let lessons: [LessonResponse]
}

// MARK: - Decodable

extension LessonsResponse: Decodable { }

// MARK: - Equatable

extension LessonsResponse: Equatable { }
