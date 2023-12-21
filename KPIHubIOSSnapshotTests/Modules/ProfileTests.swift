//
//  ProfileTests.swift
//  KPIHubIOSSnapshotTests
//
//  Created by Denys Danyliuk on 19.12.2023.
//

import XCTest
import ComposableArchitecture
import SnapshotTesting
import SwiftUI
import ProfileHomeFeature
import GeneralServices
@testable import KPIHubIOS

class ProfileTests: XCTestCase {
    override func setUp() {
        super.setUp()
//        isRecording = true
    }
    
    func testProfileNotSelected() {
        let store = StoreOf<ProfileHomeFeature>(
            initialState: ProfileHomeFeature.State(
                rozklad: ProfileHomeRozkladFeature.State(rozkladState: .notSelected)
            ),
            reducer: {
                ProfileHomeFeature()
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
    
    func testProfileSelectedGroup() {
        let store = StoreOf<ProfileHomeFeature>(
            initialState: ProfileHomeFeature.State(
                rozklad: ProfileHomeRozkladFeature.State(rozkladState: .selected(GroupResponse.mock))
            ),
            reducer: {
                ProfileHomeFeature()
            },
            withDependencies: {
                $0.analyticsService = .none()
                
                var rozkladServiceLessons = $0.rozkladServiceLessons
                rozkladServiceLessons.currentUpdatedAt = {
                    Date(timeIntervalSince1970: 1702674052)
                }
                $0.rozkladServiceLessons = rozkladServiceLessons
                
                var rozkladServiceState = $0.rozkladServiceState
                rozkladServiceState.currentState = {
                    .selected(.mock)
                }
                $0.rozkladServiceState = rozkladServiceState
            }
        )
        assertAllSnapshots {
            NavigationStack {
                ProfileHomeView(store: store)
            }
        }
    }
}

