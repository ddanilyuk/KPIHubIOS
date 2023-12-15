//
//  APIError.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation

public enum APIError: Error {
    case serviceError(statusCode: Int, APIErrorPayload)
    case unknown
}

extension APIError: Equatable { }

public struct APIErrorPayload: Codable, Equatable {
    public let reason: String?
}
