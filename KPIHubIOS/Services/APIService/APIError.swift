//
//  APIError.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation

enum APIError: Error {
    case serviceError(statusCode: Int, APIErrorPayload)
    case unknown
}

extension APIError: Equatable { }

struct APIErrorPayload: Codable, Equatable {
    let reason: String?
}
