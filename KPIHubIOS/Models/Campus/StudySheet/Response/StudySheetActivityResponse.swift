//
//  StudySheetActivityResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.07.2022.
//

import Foundation

struct StudySheetActivityResponse: Codable, Equatable {
    let date: String
    let mark: String
    let type: String
    let teacher: String
    let note: String
}
