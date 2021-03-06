//
//  LessonsResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.05.2022.
//

import Foundation

struct LessonsResponse {
    let id: UUID
    let lessons: [LessonResponse]
}

// MARK: - Decodable

extension LessonsResponse: Decodable {
    
}

// MARK: - Equatable

extension LessonsResponse: Equatable {

}
