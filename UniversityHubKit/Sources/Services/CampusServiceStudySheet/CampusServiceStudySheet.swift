//
//  CampusServiceStudySheet.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import Combine
import ComposableArchitecture

public struct CampusServiceStudySheet {
    public enum State: Equatable {
        case notLoading
        case loading
        case loaded([StudySheetItem])
    }

    public var stateStream: () -> AsyncStream<State>
    public var load: () async -> Void
    public var clean: () -> Void
}
