//
//  GroupResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 07.06.2022.
//

import Foundation

struct GroupResponse {
    let id: UUID
    let name: String
    let faculty: String?
}

extension GroupResponse: Codable { }

extension GroupResponse: Equatable { }
