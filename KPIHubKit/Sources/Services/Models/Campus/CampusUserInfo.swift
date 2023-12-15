//
//  CampusUserInfo.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Foundation

public struct CampusUserInfo: Codable, Equatable {
    // MARK: - StudyGroup

    public struct InfoItem: Codable, Equatable {
        let id: Int
        public let name: String
    }

    // MARK: - Profile

    public struct Profile: Codable, Equatable {
        let id: Int
        let profile: String
        let subdivision: InfoItem
    }

    // MARK: - Properties

    public let modules: [String]
    public let position: [InfoItem]
    public let subdivision: [InfoItem]
    public let studyGroup: InfoItem
    public let sid: String
    public let email: String
    public let scientificInterest: String
    public let username: String
    public let tgAuthLinked: Bool
    public let profiles: [Profile]
    public let id: Int
    public let userIdentifier: String
    public let fullName: String
    public let photo: String
    public let credo: String
}

extension CampusUserInfo {
    public static var mock = CampusUserInfo(
        modules: [],
        position: [],
        subdivision: [
            CampusUserInfo.InfoItem(
                id: 1,
                name: "ФІОТ"
            )
        ],
        studyGroup: CampusUserInfo.InfoItem(
            id: 1,
            name: "ІВ-82"
        ),
        sid: "",
        email: "",
        scientificInterest: "",
        username: "dda77177",
        tgAuthLinked: false,
        profiles: [],
        id: 1,
        userIdentifier: "",
        fullName: "Данилюк Денис Андрійович",
        photo: "",
        credo: ""
    )
}
