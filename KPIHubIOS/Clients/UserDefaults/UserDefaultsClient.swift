//
//  UserDefaultsClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import Foundation

struct UserDefaultsClient {

    var setVerificationID: (String) -> Void
    var getVerificationID: () -> (String)

    var setCoreLessons: ([LessonsResponse]) -> Void
    var getCoreLessons: () -> [LessonsResponse]

}

// MARK: - Key

extension UserDefaultsClient {

    enum Key: String {
        case authVerificationID
        case user
    }

}
