//
//  APIService.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 04.06.2022.
//

import URLRouting
import Routes
import Dependencies
import Foundation

typealias APIService = URLRoutingClient<RootRoute>

extension APIService {
    func request<Value: Decodable>(
        for route: Route,
        as type: Value.Type = Value.self,
        decoder: JSONDecoder = .init()
    ) async throws -> Value {
        let (data, response) = try await self.data(for: route)

        if let statusCode = (response as? HTTPURLResponse)?.statusCode {
            switch statusCode {
            case 200 ..< 300:
                return try decoder.decode(Value.self, from: data)

            case 400 ..< 500:
                let payload = try decoder.decode(APIErrorPayload.self, from: data)
                throw APIError.serviceError(statusCode: statusCode, payload)

            default:
                throw APIError.unknown
            }
        } else {
            throw APIError.unknown
        }
    }
}
