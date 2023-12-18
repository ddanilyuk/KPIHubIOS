//
//  GroupResponse.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 07.06.2022.
//

import Foundation

public struct GroupResponse {
    public let id: UUID
    public let name: String
    public let faculty: String?
    
    public init(id: UUID, name: String, faculty: String?) {
        self.id = id
        self.name = name
        self.faculty = faculty
    }
}

extension GroupResponse: Codable { }

extension GroupResponse: Equatable { }

extension GroupResponse {
    public static var mock: GroupResponse {
        GroupResponse(id: UUID(), name: "ІВ-82", faculty: "ФІОТ")
    }
}
