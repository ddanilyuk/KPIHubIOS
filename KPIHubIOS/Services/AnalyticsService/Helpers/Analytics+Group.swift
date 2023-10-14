//
//  Analytics+Group.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import Common

extension AnalyticsService {
    func setGroup(_ group: GroupResponse?) {
        setUserProperty(UserProperty.groupID(group?.id.uuidString))
        setUserProperty(UserProperty.groupName(group?.name))
        setUserProperty(UserProperty.groupFaculty(group?.faculty))
    }
}
