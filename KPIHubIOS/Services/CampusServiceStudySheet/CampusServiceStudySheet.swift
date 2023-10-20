//
//  CampusServiceStudySheet.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import Combine
import ComposableArchitecture

struct CampusServiceStudySheet {
    enum State: Equatable {
        case notLoading
        case loading
        case loaded([StudySheetItem])
    }

    var stateStream: () -> AsyncStream<State>
    var load: () async -> Void
    var clean: () -> Void
}
