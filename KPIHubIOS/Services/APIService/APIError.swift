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

    init(error: Error) {
        if let apiError = error as? APIError {
            self = apiError
        } else {
            self = .unknown
        }
    }
}

extension APIError: Equatable {

}

struct APIErrorPayload: Codable, Equatable {
    let reason: String?
}
