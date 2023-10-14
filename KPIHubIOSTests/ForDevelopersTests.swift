//
//  ForDevelopersTests.swift
//  KPIHubIOSTests
//
//  Created by Denys Danyliuk on 14.10.2023.
//

import XCTest
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
@testable import KPIHubIOS

class ForDevelopersTests: XCTestCase {
    func testScreen() {
        let store = StoreOf<ForDevelopers>(
            initialState: ForDevelopers.State(),
            reducer: {
                ForDevelopers()
            },
            withDependencies: {
                $0.analyticsService = .none()
            }
        )
        let locales = [Locale(identifier: "en-US"), Locale(identifier: "uk-UA")]
        let configs = [ViewImageConfig.iPhone8, ViewImageConfig.iPhone13, ViewImageConfig.iPhone13ProMax]
        
        createPairs(configs, locales).forEach { config, locale in
            let profileView = NavigationStack {
                ForDevelopersView(store: store)
            }
            .environment(\.locale, locale)
            assertSnapshot(
                of: profileView,
                as: .image(perceptualPrecision: 0.99, layout: .device(config: config)),
                named: "\(config.description)-\(locale.identifier)",
                record: false
            )
        }
    }
}
