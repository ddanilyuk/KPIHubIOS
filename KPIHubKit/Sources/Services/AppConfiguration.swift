//
//  AppConfiguration.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.07.2022.
//

import Foundation

public struct AppConfiguration {
    public let appName: String
    public let apiURL: String
    public let apiEnvironment: ApiEnvironment
    public let completeAppVersion: String?
}

extension AppConfiguration {
    static func live(bundle: Bundle) -> AppConfiguration {
        AppConfiguration(bundle: bundle)
    }
    
    init(bundle: Bundle) {
// TODO: Bundle is not working too
//        guard
//            let appName = bundle.object(forInfoDictionaryKey: Keys.appName) as? String,
//            let apiEnvironmentKey = bundle.object(forInfoDictionaryKey: Keys.apiEnvironment) as? String,
//            let apiEnvironment = ApiEnvironment(rawValue: apiEnvironmentKey)
//        else {
//            fatalError("Couldn't init environment from bundle: \(bundle.infoDictionary ?? [:])")
//        }
        let apiEnvironment = ApiEnvironment.production

        let version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildNumber = bundle.infoDictionary?["CFBundleVersion"] as? String
        if let version, let buildNumber {
            let appVersionString = "\(version) (\(buildNumber))"
            completeAppVersion = apiEnvironment.isTestEnvironment
            ? appVersionString + " (\(apiEnvironment.shortDescription))"
            : appVersionString
        } else {
            completeAppVersion = nil
        }

        self.appName = "appName"
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
    static let liveValue = AppConfiguration.live(bundle: Bundle.main) // TODO: Fix
    static let testValue = AppConfiguration.mock()
}

extension DependencyValues {
    public var appConfiguration: AppConfiguration {
        get { self[AppConfigurationKey.self] }
        set { self[AppConfigurationKey.self] = newValue }
    }
}

public enum ApiEnvironment: String {
    case development
    case production

    public var isTestEnvironment: Bool {
        self != .production
    }

    public var url: String {
        switch self {
        case .development:
            return "http://192.168.31.105:8080"
        case .production:
            return "http://kpihub.xyz"
        }
    }

    public var shortDescription: String {
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
