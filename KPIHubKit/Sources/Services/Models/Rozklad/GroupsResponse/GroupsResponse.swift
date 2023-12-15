//
//  GroupsResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import Foundation

public struct GroupsResponse {
    public var groups: [GroupResponse]
}

extension GroupsResponse: Codable { }

extension GroupsResponse: Equatable { }
