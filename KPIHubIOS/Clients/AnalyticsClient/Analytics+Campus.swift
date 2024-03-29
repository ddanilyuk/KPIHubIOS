//
//  Analytics+Campus.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 27.09.2022.
//

import Foundation

extension AnalyticsClient {
    func setCampusUser(_ campusUserInfo: CampusUserInfo?) {
        setUserProperty(UserProperty.cathedra(campusUserInfo?.subdivision.first?.name))
        setUserProperty(UserProperty.userFullName(campusUserInfo?.fullName))
        setUserProperty(UserProperty.userEmail(campusUserInfo?.email))
    }
}
