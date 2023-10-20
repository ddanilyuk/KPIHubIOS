//
//  UserProperty.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation

public struct UserProperty: Equatable {
    public let name: String
    public var value: String?
}

extension UserProperty {
    
    public static func groupID(_ value: String?) -> UserProperty {
        UserProperty(name: "groupID", value: value)
    }
    
    public static func groupName(_ value: String?) -> UserProperty {
        UserProperty(name: "groupName", value: value)
    }
    
    public static func groupFaculty(_ value: String?) -> UserProperty {
        UserProperty(name: "groupFaculty", value: value)
    }
    
    public static func cathedra(_ value: String?) -> UserProperty {
        UserProperty(name: "cathedra", value: value)
    }
    
    public static func userFullName(_ value: String?) -> UserProperty {
        UserProperty(name: "userFullName", value: value)
    }
    
    public static func userEmail(_ value: String?) -> UserProperty {
        UserProperty(name: "userEmail", value: value)
    }

}
