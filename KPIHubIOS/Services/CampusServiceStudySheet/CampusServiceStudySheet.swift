//
//  CampusServiceStudySheet.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import Combine
import ComposableArchitecture
import Common

struct CampusServiceStudySheet {
    enum State: Equatable {
        case notLoading
        case loading
        case loaded([StudySheetItem])
    }

    let subject: CurrentValueSubject<State, Never>

    let load: () async -> Void
    let clean: () -> Void
}
