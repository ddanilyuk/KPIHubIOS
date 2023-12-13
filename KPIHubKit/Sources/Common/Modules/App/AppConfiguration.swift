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
}

extension AppConfiguration {
    static func live(bundle: Bundle) -> AppConfiguration {
        AppConfiguration(bundle: bundle)
    }
    
    init(bundle: Bundle) {
        guard
            let appName = bundle.object(forInfoDictionaryKey: Keys.appName) as? String,
            let apiEnvironmentKey = bundle.object(forInfoDictionaryKey: Keys.apiEnvironment) as? String,
            let apiEnvironment = ApiEnvironment(rawValue: apiEnvironmentKey)
        else {
            fatalError("Couldn't init environment from bundle: \(bundle.infoDictionary ?? [:])")
        }

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        if let version, let buildNumber {
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

extension AppConfiguration {
    static func mock() -> AppConfiguration {
        AppConfiguration(
            appName: "KPI Hub",
            apiURL: "http://kpihub.xyz",
            apiEnvironment: .development,
            completeAppVersion: "1.0 (1)"
        )
    }
}

import Dependencies

private enum AppConfigurationKey: DependencyKey {
    static let liveValue = AppConfiguration.live(bundle: Bundle.main)
    static let testValue = AppConfiguration.mock()
}

extension DependencyValues {
    var appConfiguration: AppConfiguration {
        get { self[AppConfigurationKey.self] }
        set { self[AppConfigurationKey.self] = newValue }
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
            return "http://192.168.31.105:8080"
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
