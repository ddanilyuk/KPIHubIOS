//
//  StudySheetResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import Foundation

public struct StudySheetResponse: Codable, Equatable {
    public let studySheet: [StudySheetItemResponse]
}
