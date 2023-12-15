//
//  Event.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation

// swiftlint:disable let_var_whitespace
public struct Event: Equatable {
    let name: String
    var parameters: [String: String]?
}

extension Event {
    public enum Onboarding {
        public static let onboardingAppeared = Event(name: "onboarding_appeared")
        public static let onboardingPassed = Event(name: "onboarding_passed")
        
        public static let groupPickerAppeared = Event(name: "group_picker_appeared")
        public static let groupsLoadSuccess = Event(name: "groups_load_success")
        public static let groupsLoadFailed = Event(name: "groups_load_failed")
        
        public static let groupPickerSelect = Event(name: "group_picker_select")
        
        public static let campusLoginAppeared = Event(name: "campus_login_appeared")
        public static let campusLogin = Event(name: "campus_login")
        
        public static let campusUserLoadSuccess = Event(name: "campus_user_load_success")
        public static let campusUserLoadInvalidCredentials = Event(name: "campus_user_load_invalid_credentials")
        public static let campusUserLoadFailed = Event(name: "campus_user_load_failed")

        public static let campusUserGroupFound = Event(name: "campus_user_group_found")
        public static let campusUserGroupNotFound = Event(name: "campus_user_group_not_found")
        public static let campusUserGroupFailed = Event(name: "campus_user_group_failed")
    }

    public enum Rozklad {
        public static let groupRozkladAppeared = Event(name: "group_rozklad_appeared")
    
        public enum Place: String {
            case campus = "campus"
            case campusUserInput = "campus_user_input"
            case onboarding = "onboarding"
            case rozkladTab = "rozklad_tab"
            case profileReload = "profile_reload"
        }
        public static func lessonsLoadSuccess(place: Place) -> Event {
            Event(
                name: "lessons_load_success",
                parameters: ["place": place.rawValue]
            )
        }
        public static func lessonsLoadFailed(place: Place) -> Event {
            Event(
                name: "lessons_load_failed",
                parameters: ["place": place.rawValue]
            )
        }
    }
    
    public enum LessonDetails {
        public static func appeared(id: String, name: String) -> Event {
            Event(
                name: "lesson_details_appeared",
                parameters: ["lesson_id": id, "lesson_name": name]
            )
        }
        public static let editTapped = Event(name: "lesson_details_edit_tapped")
        public static let editNamesAppeared = Event(name: "lesson_details_edit_names_appeared")
        public static let editTeachersAppeared = Event(name: "lesson_details_edit_teachers_appeared")
        public static let editNamesApply = Event(name: "lesson_details_edit_names_apply")
        public static let editTeachersApply = Event(name: "lesson_details_edit_teachers_apply")
        public static let removeLessonApply = Event(name: "lesson_details_remove_lesson_apply")
    }
    
    public enum Campus {
        public static let campusHomeAppeared = Event(name: "campus_home_appeared")
        
        public static func studySheetLoadSuccess(itemsCount: Int) -> Event {
            Event(name: "study_sheet_load_success", parameters: ["study_sheet_items_count": "\(itemsCount)"])
        }
        public static let studySheetLoadFail = Event(name: "study_sheet_load_fail")
        public static let studySheetAppeared = Event(name: "study_sheet_appeared")
        public static let studySheetItemDetailAppeared = Event(name: "study_sheet_item_detail_appeared")
    }
    
    public enum Profile {
        public static let profileHomeAppeared = Event(name: "profile_home_appeared")
        public static let reloadRozkladTapped = Event(name: "profile_reload_rozklad_tapped")
        public static let reloadRozklad = Event(name: "profile_reload_rozklad")
        public static let changeGroupTapped = Event(name: "profile_change_group")
        public static let changeGroup = Event(name: "profile_change_group")
        public static let selectGroup = Event(name: "profile_select_group")
        public static let campusLogout = Event(name: "profile_campus_logout")
        public static let campusLogoutTapped = Event(name: "profile_campus_logout")
        public static let campusLogin = Event(name: "profile_campus_login")
        public static func changeWeek(_ value: Bool) -> Event {
            Event(name: "profile_change_week", parameters: ["week_toggle_value": value ? "true" : "false"])
        }
        public static let forDevelopersAppeared = Event(name: "profile_for_developers_appeared")
    }
}
// swiftlint:enable let_var_whitespace
