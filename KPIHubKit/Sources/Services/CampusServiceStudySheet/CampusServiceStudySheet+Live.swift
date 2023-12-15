//
//  CampusServiceStudySheet+Live.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 22.08.2023.
//

import Foundation
import Dependencies
import Combine
import Routes
import ComposableArchitecture

extension CampusServiceStudySheet {
    static func live() -> CampusServiceStudySheet {
        @Dependency(\.apiService) var apiService
        @Dependency(\.keychainService) var keychainService
        @Dependency(\.userDefaultsService) var userDefaultsService
        
        let subject = CurrentValueSubject<State, Never>(.notLoading)

        return CampusServiceStudySheet(
            stateStream: { subject.values.eraseToStream() },
            load: {
                guard
                    let username = keychainService.get(key: .campusUsername),
                    let password = keychainService.get(key: .campusPassword)
                else {
                    subject.send(.notLoading)
                    return
                }
                let campusLoginQuery = CampusLoginQuery(
                    username: username,
                    password: password
                )
                subject.send(.loading)
                
                do {
                    let response = try await apiService.decodedResponse(
                        for: .api(.campus(.studySheet(campusLoginQuery))),
                        as: StudySheetResponse.self
                    )
                    let studySheet = response.value.studySheet.map { StudySheetItem(studySheetItemResponse: $0) }
                    subject.send(.loaded(studySheet))
                } catch {
                    subject.send(.notLoading)
                }
            },
            clean: {
                subject.send(.notLoading)
            }
        )
    }
}
