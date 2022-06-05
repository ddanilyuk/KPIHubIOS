//
//  StudySheetResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import Foundation

struct StudySheetResponse: Codable, Equatable {
    let studySheet: [StudySheetItemResponse]
}

struct StudySheetItemResponse: Codable, Equatable {

    let id: Int
    let year: String
    let semester: Int
    let link: String
    let name: String
    let teachers: [String]

    let activities: [StudySheetActivityResponse]
}

struct StudySheetActivityResponse: Codable, Equatable {

    let date: String
    let mark: String
    let type: String
    let teacher: String
    let note: String

}
