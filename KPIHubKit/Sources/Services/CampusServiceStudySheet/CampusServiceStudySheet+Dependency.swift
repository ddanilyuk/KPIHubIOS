//
//  CampusServiceStudySheet+Dependency.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Dependencies

extension DependencyValues {
    private enum CampusServiceStudySheetKey: DependencyKey {
        static let testValue = CampusServiceStudySheet.mock()
        static let liveValue = CampusServiceStudySheet.live()
    }
    
    public var campusServiceStudySheet: CampusServiceStudySheet {
        get { self[CampusServiceStudySheetKey.self] }
        set { self[CampusServiceStudySheetKey.self] = newValue }
    }
}
