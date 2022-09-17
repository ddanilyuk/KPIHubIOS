//
//  AnalyticsClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import ComposableArchitecture
import Firebase
import FirebaseAnalytics
import XCTestDynamicOverlay

private enum AnalyticsClientKey: DependencyKey {
    static let liveValue = AnalyticsClient.live()
    static let testValue = AnalyticsClient.failing
}

extension DependencyValues {
    var analyticsClient: AnalyticsClient {
        get { self[AnalyticsClientKey.self] }
        set { self[AnalyticsClientKey.self] = newValue }
    }
}

\
struct AnalyticsClient {
    var track: (_ event: Event) -> Void
    var setUserProperty: (_ userProperty: UserProperty) -> Void
}

extension AnalyticsClient {
    
    static func live() -> Self {
        Self(
            track: { event in
                Analytics.logEvent(event.name, parameters: event.parameters)
            },
            setUserProperty: { userProperty in
                Analytics.setUserProperty(userProperty.value, forName: userProperty.name)
            }
        )
    }
    
    static var failing = Self(
        track: XCTUnimplemented("\(Self.self).track"),
        setUserProperty: XCTUnimplemented("\(Self.self).setUserProperty")
    )
    
}

struct UserProperty: Equatable {
    let name: String
    let value: String
}


struct Event: Equatable {
    let name: String
    var parameters: [String: String]?
}

extension Event {
    
    enum Onboarding {
        static let onboardingPassed = Event(name: "onboarding_passed")
        static let selectGroup = Event(name: "select_group")
        static let campusLogin = Event(name: "campus_login")
    }

    enum Rozklad {
        static let groupRozkladTabAppeared = Event(name: "group_rozklad_tab_appeared")
        static let lessonSelected = Event(name: "lesson_selected")
    }
    
    enum Campus {
        static let campusTabAppeared = Event(name: "campus_tab_appeared")
        static let studySheetAppeared = Event(name: "study_sheet_appeared")
    }
    
    enum Profile {
        static let profileTabAppeared = Event(name: "profile_tab_appeared")
        static let rozkladRefreshed = Event(name: "rozklad_refreshed")
        static let groupChanged = Event(name: "group_changed")
        static let campusLogout = Event(name: "campus_logout")
        static let weekChanged = Event(name: "week_changed")
        static let openForDevelopers = Event(name: "open_for_developers")
    }
    
}

// User data
// groupID
// groupName
// caphedraName
