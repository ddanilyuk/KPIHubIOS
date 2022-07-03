//
//  GroupsResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import Foundation

struct GroupsResponse {
    var groups: [GroupResponse]
}

extension GroupsResponse: Codable {

}

extension GroupsResponse: Equatable {

}
