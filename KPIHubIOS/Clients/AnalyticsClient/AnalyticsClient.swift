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
    var value: String?
}

extension UserProperty {
    
    static func groupID(_ value: String?) -> UserProperty {
        UserProperty(name: "groupID", value: value)
    }
    
    static func groupName(_ value: String?) -> UserProperty {
        UserProperty(name: "groupName", value: value)
    }
    
    static func groupFaculty(_ value: String?) -> UserProperty {
        UserProperty(name: "groupFaculty", value: value)
    }
    
    static func cathedra(_ value: String?) -> UserProperty {
        UserProperty(name: "cathedra", value: value)
    }
}


struct Event: Equatable {
    let name: String
    var parameters: [String: String]?
}

extension Event {
    
    enum Onboarding {
        static let onboardingAppeared = Event(name: "onboarding_appeared") // Done
        static let onboardingPassed = Event(name: "onboarding_passed") // Done
        
        static let groupPickerAppeared = Event(name: "group_picker_appeared") // Done
        static let groupsLoadSuccess = Event(name: "groups_load_success") // Done
        static let groupsLoadFailed = Event(name: "groups_load_failed") // Done
        
        static let groupPickerSelect = Event(name: "group_picker_select") // Done
        
        static let campusLoginAppeared = Event(name: "campus_login_appeared") // Done
        static let campusLogin = Event(name: "campus_login") // Done
        
        static let campusUserLoadSuccess = Event(name: "campus_user_load_success") // Done
        static let campusUserLoadInvalidCredentials = Event(name: "campus_user_load_invalid_credentials") // Done
        static let campusUserLoadFailed = Event(name: "campus_user_load_failed") // Done

        static let campusUserGroupFound = Event(name: "campus_user_group_found") // Done
        static let campusUserGroupNotFound = Event(name: "campus_user_group_not_found") // Done
        static let campusUserGroupFailed = Event(name: "campus_user_group_failed") // Done
    }

    enum Rozklad {
        static let groupRozkladTabAppeared = Event(name: "group_rozklad_tab_appeared")
        static let lessonSelected = Event(name: "lesson_selected")
        
        enum GroupOrigin: String {
            case campus = "campus"
            case campusUserInput = "campus_user_input"
            case onboarding = "onboarding"
            case rozkladTab = "rozkladTab"
            case reload = "reload"
        }
        static func lessonsLoadSuccess(groupOrigin: GroupOrigin) -> Event {
            Event(
                name: "lessons_load_success",
                parameters: ["groupOrigin": groupOrigin.rawValue]
            )
        }
        static func lessonsLoadFailed(groupOrigin: GroupOrigin) -> Event {
            Event(
                name: "lessons_load_failed",
                parameters: ["groupOrigin": groupOrigin.rawValue]
            )
        }
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
