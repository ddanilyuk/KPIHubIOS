//
//  AppConfiguration.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.07.2022.
//

import Foundation

struct AppConfiguration {
    let appName: String
    let apiURL: String
    let apiEnvironment: ApiEnvironment
    let completeAppVersion: String?

    static func live(bundle: Bundle) -> AppConfiguration {
        AppConfiguration(bundle: bundle)
    }

    private init(bundle: Bundle) {
        guard
            let appName = bundle.object(forInfoDictionaryKey: Keys.appName) as? String,
            let apiEnvironmentKey = bundle.object(forInfoDictionaryKey: Keys.apiEnvironment) as? String,
            let apiEnvironment = ApiEnvironment(rawValue: apiEnvironmentKey)
        else {
            fatalError("Couldn't init environment from bundle: \(bundle.infoDictionary ?? [:])")
        }

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            let appVersionString = "\(version) (\(buildNumber))"
            completeAppVersion = apiEnvironment.isTestEnvironment
            ? appVersionString + " (\(apiEnvironment.shortDescription))"
            : appVersionString
        } else {
            completeAppVersion = nil
        }

        self.appName = appName
        self.apiURL = apiEnvironment.url
        self.apiEnvironment = apiEnvironment
    }
    
}

enum ApiEnvironment: String {
    case development
    case production

    var isTestEnvironment: Bool {
        self != .production
    }

    var url: String {
        switch self {
        case .development:
            return "http://192.168.31.179:8080"
        case .production:
            return "http://kpihub.xyz"
        }
    }

    var shortDescription: String {
        switch self {
        case .development:
            return "Dev"
        case .production:
            return "Prod"
        }
    }
}

private enum Keys {
    static let appName = "KPIHubIOS_APP_NAME"
    static let apiEnvironment = "KPIHubIOS_ENVIRONMENT"
}
