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
// TODO: Cleon on logout
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
        static let groupRozkladAppeared = Event(name: "group_rozklad_appeared") // DONE
        
        static func lessonDetailsAppeared(id: String, name: String) -> Event {
            Event(
                name: "lesson_details_appeared",
                parameters: ["lesson_id": id, "lesson_name": name]
            )
        } // DONE
        
        static let lessonDetailsEditTapped = Event(name: "lesson_details_edit_tapped") // DONE
        static let lessonDetailsEditNamesAppeared = Event(name: "lesson_details_edit_names_appeared") // DONE
        static let lessonDetailsEditTeachersAppeared = Event(name: "lesson_details_edit_teachers_appeared") // DONE
        static let lessonDetailsEditNamesApply = Event(name: "lesson_details_edit_names_apply") // DONE
        static let lessonDetailsEditTeachersApply = Event(name: "lesson_details_edit_teachers_apply") // DONE

        enum GroupOrigin: String {
            case campus = "campus"
            case campusUserInput = "campus_user_input"
            case onboarding = "onboarding"
            case rozkladTab = "rozkladTab"
            case profileReload = "profile_reload"
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
        // TODO: If study sheet loaded
        static let studySheetAppeared = Event(name: "study_sheet_appeared")
    }
    
    enum Profile {
        static let profileHomeAppeared = Event(name: "profile_home_appeared") // DONE    MOVE to ProfileHome?
        static let reloadRozkladTapped = Event(name: "profile_reload_rozklad_tapped") // DONE
        static let reloadRozklad = Event(name: "profile_reload_rozklad") // DONE
        static let changeGroupTapped = Event(name: "profile_change_group") // DONE
        static let changeGroup = Event(name: "profile_change_group") // DONE
        static let selectGroup = Event(name: "profile_select_group") // DONE
        static let campusLogout = Event(name: "profile_campus_logout") // DONE
        static let campusLogoutTapped = Event(name: "profile_campus_logout") // DONE
        static let campusLogin = Event(name: "profile_campus_login") // DONE
        static func changeWeek(_ value: Bool) -> Event {
            Event(name: "profile_change_week", parameters: ["week_toggle_value": value ? "true" : "false"])
        } // DONE
        static let forDevelopersAppeared = Event(name: "profile_for_developers_appeared") // DONE
    }
}

// User data
// groupID
// groupName
// caphedraName
