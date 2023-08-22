//
//  CampusServiceStudySheet+Mock.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import Combine

extension CampusServiceStudySheet {
    static func mock() -> CampusServiceStudySheet {
        CampusServiceStudySheet(
            subject: CurrentValueSubject<State, Never>(.notLoading),
            load: { .none },
            clean: { }
        )
    }
}