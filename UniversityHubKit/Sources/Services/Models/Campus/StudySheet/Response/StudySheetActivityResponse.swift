//
//  StudySheetActivityResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.07.2022.
//

import Foundation

public struct StudySheetActivityResponse: Codable, Equatable {
    public let date: String
    public let mark: String
    public let type: String
    public let teacher: String
    public let note: String
}
