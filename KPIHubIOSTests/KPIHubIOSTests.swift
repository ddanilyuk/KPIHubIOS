//
//  KPIHubIOSTests.swift
//  KPIHubIOSTests
//
//  Created by Denys Danyliuk on 19.05.2022.
//

import XCTest
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
@testable import KPIHubIOS

class KPIHubIOSTests: XCTestCase {
    func testProfile() {
//        isRecording = true

        let store = StoreOf<ProfileHome>(
            initialState: ProfileHome.State(),
            reducer: {
                ProfileHome()
            },
            withDependencies: {
                $0.analyticsService = .none()
            }
        )
        let locales = [Locale(identifier: "en-US"), Locale(identifier: "uk-UA")]
        let configs = [ViewImageConfig.iPhone8, ViewImageConfig.iPhone13, ViewImageConfig.iPhone13ProMax]
        
        let filePath: StaticString
            
        if Self.isCIEnvironment {
            filePath = XCTest.xcodeCloudFilePath
        } else {
            filePath = #file
        }
        
        createPairs(configs, locales).forEach { config, locale in
            let profileView = NavigationStack {
                ProfileHomeView(store: store)
            }
            .environment(\.locale, locale)
            assertSnapshot(
                of: profileView,
                as: .image(perceptualPrecision: 0.99, layout: .device(config: config)),
                named: "\(config.description)-\(locale.identifier)",
                file: filePath
            )
        }
    }
}

extension ViewImageConfig {
    var description: String {
        switch self.size {
        case ViewImageConfig.iPhone8.size:
            return "iPhone8"
        case ViewImageConfig.iPhone13.size:
            return "iPhone13"
        case ViewImageConfig.iPhone13ProMax.size:
            return "iPhone13ProMax"
        default:
            return "no info"
        }
    }
}


func createPairs<T, U>(_ array1: [T], _ array2: [U]) -> [(T, U)] {
    var pairs: [(T, U)] = []
    
    for item1 in array1 {
        for item2 in array2 {
            pairs.append((item1, item2))
        }
    }
    
    return pairs
}
