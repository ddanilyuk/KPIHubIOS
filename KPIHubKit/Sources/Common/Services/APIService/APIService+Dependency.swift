//
//  APIService+Dependency.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Dependencies
import URLRouting
import Routes

extension DependencyValues {
    private enum APIServiceKey: DependencyKey {
        static let testValue = APIService.failing
        
        static let liveValue: APIService = {
            @Dependency(\.appConfiguration) var appConfiguration
            return APIService.live(
                router: rootRouter.baseURL(appConfiguration.apiURL)
            )
        }()
    }
    
    var apiService: APIService {
        get { self[APIServiceKey.self] }
        set { self[APIServiceKey.self] = newValue }
    }
}
