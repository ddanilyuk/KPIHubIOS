//
//  ProfileTests.swift
//  ProfileTests
//
//  Created by Denys Danyliuk on 19.05.2022.
//

import XCTest
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
@testable import KPIHubIOS

class ProfileTests: XCTestCase {
    func testProfile() {
        let store = StoreOf<ProfileHome>(
            initialState: ProfileHome.State(),
            reducer: {
                ProfileHome()
            },
            withDependencies: {
                $0.analyticsService = .none()
            }
        )
        assertAllSnapshots {
            NavigationStack {
                ProfileHomeView(store: store)
            }
        }
    }
}
