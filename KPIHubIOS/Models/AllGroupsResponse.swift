//
//  AllGroupsResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import Foundation

struct AllGroupsResponse {
    var groups: [GroupResponse]
}

extension AllGroupsResponse: Codable {

}

extension AllGroupsResponse: Equatable {

}
