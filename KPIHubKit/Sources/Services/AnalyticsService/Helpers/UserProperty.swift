//
//  UserProperty.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation

public struct UserProperty: Equatable {
    let name: String
    var value: String?
    
    public init(name: String, value: String? = nil) {
        self.name = name
        self.value = value
    }
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
    
    static func userFullName(_ value: String?) -> UserProperty {
        UserProperty(name: "userFullName", value: value)
    }
    
    static func userEmail(_ value: String?) -> UserProperty {
        UserProperty(name: "userEmail", value: value)
    }
}
