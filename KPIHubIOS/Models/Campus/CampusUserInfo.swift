//
//  CampusUserInfo.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Foundation

struct CampusUserInfo: Codable, Equatable {
    // MARK: - StudyGroup

    struct InfoItem: Codable, Equatable {
        let id: Int
        let name: String
    }

    // MARK: - Profile

    struct Profile: Codable, Equatable {
        let id: Int
        let profile: String
        let subdivision: InfoItem
    }

    // MARK: - Properties

    let modules: [String]
    let position: [InfoItem]
    let subdivision: [InfoItem]
    let studyGroup: InfoItem
    let sid: String
    let email: String
    let scientificInterest: String
    let username: String
    let tgAuthLinked: Bool
    let profiles: [Profile]
    let id: Int
    let userIdentifier: String
    let fullName: String
    let photo: String
    let credo: String
}

extension CampusUserInfo {
    static var mock = CampusUserInfo(
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
