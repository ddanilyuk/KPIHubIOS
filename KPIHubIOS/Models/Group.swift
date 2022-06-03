//
//  GroupResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import Foundation

struct GroupResponse {
    let id: UUID
    let name: String
}

extension GroupResponse: Codable {

}

extension GroupResponse: Equatable {

}
