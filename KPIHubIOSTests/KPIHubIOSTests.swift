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
//        let store = StoreOf<ProfileHome>(
//            initialState: .init()
//        ), reducer: ({
//            ProfileHome()
//        }),
        let store = StoreOf<ProfileHome>(
            initialState: ProfileHome.State(),
            reducer: {
                ProfileHome()
            },
            withDependencies: {
                $0.analyticsService = .none()
            }
        )
        let profileView = NavigationStack {
            ProfileHomeView(store: store)
        }
        isRecording = true
//        let viewController =
        assertSnapshot(of: profileView, as: .image(perceptualPrecision: 0.99, layout: .device(config: .iPhone13Pro)))
    }
}
