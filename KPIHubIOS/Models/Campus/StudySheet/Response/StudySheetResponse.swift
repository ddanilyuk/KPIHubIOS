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
