//
//  StudySheetItemResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.07.2022.
//

import Foundation

public struct StudySheetItemResponse: Codable, Equatable {
    public let id: Int
    public let year: String
    public let semester: Int
    public let link: String
    public let name: String
    public let teachers: [String]
    public let activities: [StudySheetActivityResponse]
}
