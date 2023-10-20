//
//  StudySheetItemResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.07.2022.
//

import Foundation

struct StudySheetItemResponse: Codable, Equatable {
    let id: Int
    let year: String
    let semester: Int
    let link: String
    let name: String
    let teachers: [String]

    let activities: [StudySheetActivityResponse]
}
