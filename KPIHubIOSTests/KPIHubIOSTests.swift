//
//  KPIHubIOSTests.swift
//  KPIHubIOSTests
//
//  Created by Denys Danyliuk on 19.05.2022.
//

import XCTest
import ComposableArchitecture
import SnapshotTesting
@testable import KPIHubIOS

class KPIHubIOSTests: XCTestCase {
    func testProfile() {
        let store = StoreOf<ProfileHome>(initialState: .init()) {
            ProfileHome()
        }
        let profileView = ProfileHomeView(store: store)
        isRecording = false
//        let viewController =
        assertSnapshot(of: profileView, as: .image(perceptualPrecision: 0.99, layout: .device(config: .iPhone13Pro)))
    }
}
