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
            subject: subject,
            load: {
                guard
                    let username = keychainService.get(key: .campusUsername),
                    let password = keychainService.get(key: .campusPassword)
                else {
                    subject.send(.notLoading)
                    return .none
                }
                let campusLoginQuery = CampusLoginQuery(
                    username: username,
                    password: password
                )
                subject.send(.loading)
                
                let task: EffectPublisher<[StudySheetItem], Error> = EffectPublisher.task {
                    let result = try await apiService.decodedResponse(
                        for: .api(.campus(.studySheet(campusLoginQuery))),
                        as: StudySheetResponse.self
                    )
                    return result.value.studySheet.map { StudySheetItem(studySheetItemResponse: $0) }
                }
                return task
                    .on(
                        value: { subject.send(.loaded($0)) },
                        error: { _ in subject.send(.notLoading) }
                    )
                    .ignoreOutput(setOutputType: Void.self)
                    .ignoreFailure()
                    .eraseToEffect()
            },
            clean: {
                subject.send(.notLoading)
            }
        )
    }
}
