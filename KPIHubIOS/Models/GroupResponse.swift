//
//  GroupResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import Foundation

struct GroupResponse {
    var groups: [Group]
}

extension GroupResponse: Codable {

}

extension GroupResponse: Equatable {

}
