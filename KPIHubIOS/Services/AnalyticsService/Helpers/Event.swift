//
//  Event.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation

// swiftlint:disable let_var_whitespace
struct Event: Equatable {
    let name: String
    var parameters: [String: String]?
}

extension Event {
    
    enum Onboarding {
        static let onboardingAppeared = Event(name: "onboarding_appeared")
        static let onboardingPassed = Event(name: "onboarding_passed")
        
        static let groupPickerAppeared = Event(name: "group_picker_appeared")
        static let groupsLoadSuccess = Event(name: "groups_load_success")
        static let groupsLoadFailed = Event(name: "groups_load_failed")
        
        static let groupPickerSelect = Event(name: "group_picker_select")
        
        static let campusLoginAppeared = Event(name: "campus_login_appeared")
        static let campusLogin = Event(name: "campus_login")
        
        static let campusUserLoadSuccess = Event(name: "campus_user_load_success")
        static let campusUserLoadInvalidCredentials = Event(name: "campus_user_load_invalid_credentials")
        static let campusUserLoadFailed = Event(name: "campus_user_load_failed")

        static let campusUserGroupFound = Event(name: "campus_user_group_found")
        static let campusUserGroupNotFound = Event(name: "campus_user_group_not_found")
        static let campusUserGroupFailed = Event(name: "campus_user_group_failed")
    }

    enum Rozklad {
        static let groupRozkladAppeared = Event(name: "group_rozklad_appeared")
    
        enum Place: String {
            case campus = "campus"
            case campusUserInput = "campus_user_input"
            case onboarding = "onboarding"
            case rozkladTab = "rozklad_tab"
            case profileReload = "profile_reload"
        }
        static func lessonsLoadSuccess(place: Place) -> Event {
            Event(
                name: "lessons_load_success",
                parameters: ["place": place.rawValue]
            )
        }
        static func lessonsLoadFailed(place: Place) -> Event {
            Event(
                name: "lessons_load_failed",
                parameters: ["place": place.rawValue]
            )
        }
    }
    
    enum LessonDetails {
        static func appeared(id: String, name: String) -> Event {
            Event(
                name: "lesson_details_appeared",
                parameters: ["lesson_id": id, "lesson_name": name]
            )
        }
        static let editTapped = Event(name: "lesson_details_edit_tapped")
        static let editNamesAppeared = Event(name: "lesson_details_edit_names_appeared")
        static let editTeachersAppeared = Event(name: "lesson_details_edit_teachers_appeared")
        static let editNamesApply = Event(name: "lesson_details_edit_names_apply")
        static let editTeachersApply = Event(name: "lesson_details_edit_teachers_apply")
        static let removeLessonApply = Event(name: "lesson_details_remove_lesson_apply")
    }
    
    enum Campus {
        static let campusHomeAppeared = Event(name: "campus_home_appeared")
        
        static func studySheetLoadSuccess(itemsCount: Int) -> Event {
            Event(name: "study_sheet_load_success", parameters: ["study_sheet_items_count": "\(itemsCount)"])
        }
        static let studySheetLoadFail = Event(name: "study_sheet_load_fail")
        static let studySheetAppeared = Event(name: "study_sheet_appeared")
        static let studySheetItemDetailAppeared = Event(name: "study_sheet_item_detail_appeared")
    }
    
    enum Profile {
        static let profileHomeAppeared = Event(name: "profile_home_appeared")
        static let reloadRozkladTapped = Event(name: "profile_reload_rozklad_tapped")
        static let reloadRozklad = Event(name: "profile_reload_rozklad")
        static let changeGroupTapped = Event(name: "profile_change_group")
        static let changeGroup = Event(name: "profile_change_group")
        static let selectGroup = Event(name: "profile_select_group")
        static let campusLogout = Event(name: "profile_campus_logout")
        static let campusLogoutTapped = Event(name: "profile_campus_logout")
        static let campusLogin = Event(name: "profile_campus_login")
        static func changeWeek(_ value: Bool) -> Event {
            Event(name: "profile_change_week", parameters: ["week_toggle_value": value ? "true" : "false"])
        }
        static let forDevelopersAppeared = Event(name: "profile_for_developers_appeared")
    }
}
// swiftlint:enable let_var_whitespace
