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
        assertAllSnapshots {
            NavigationStack {
               ForDevelopersView(store: store)
           }
        }
    }
}
