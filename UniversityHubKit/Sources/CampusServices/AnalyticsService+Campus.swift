//
//  AnalyticsService+Campus.swift
//
//
//  Created by Denys Danyliuk on 20.12.2023.
//

import Services
import CampusModels

extension AnalyticsService {
    public func setCampusUser(_ campusUserInfo: CampusUserInfo?) {
        setUserProperty(UserProperty.cathedra(campusUserInfo?.subdivision.first?.name))
        setUserProperty(UserProperty.userFullName(campusUserInfo?.fullName))
        setUserProperty(UserProperty.userEmail(campusUserInfo?.email))
    }
}
