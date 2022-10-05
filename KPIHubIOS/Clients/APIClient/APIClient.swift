//
//  APIClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 04.06.2022.
//

import URLRouting
import Foundation
import Routes
import Dependencies

typealias APIClient = URLRoutingClient<RootRoute>

private enum APIClientKey: TestDependencyKey {
    static let testValue = APIClient.failing
}

extension APIClientKey: DependencyKey {
    static let liveValue: APIClient = APIClient.live(
        router: rootRouter.baseURL(DependencyValues._current.appConfiguration.apiURL)
    )
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}

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

extension APIClient {

    @available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
    public func request<Value: Decodable>(
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
