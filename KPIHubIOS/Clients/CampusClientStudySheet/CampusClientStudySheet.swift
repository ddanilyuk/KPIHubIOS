//
//  CampusClientStudySheet.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
import Combine
import Routes
import ComposableArchitecture

private enum CampusClientStudySheetKey: TestDependencyKey {
    static let testValue = CampusClientStudySheet.mock()
}

extension CampusClientStudySheetKey: DependencyKey {
    static let liveValue = CampusClientStudySheet.live(
        apiClient: DependencyValues.current.apiClient,
        userDefaultsClient: DependencyValues.current.userDefaultsClient,
        keychainClient: DependencyValues.current.keychainClient
    )
}

extension DependencyValues {
    var campusClientStudySheet: CampusClientStudySheet {
        get { self[CampusClientStudySheetKey.self] }
        set { self[CampusClientStudySheetKey.self] = newValue }
    }
}

struct CampusClientStudySheet {

    enum State: Equatable {
        case notLoading
        case loading
        case loaded([StudySheetItem])
    }

    let subject: CurrentValueSubject<State, Never>

    let load: () -> Effect<Void, Never>
    let clean: () -> Void

    static func live(
        apiClient: APIClient,
        userDefaultsClient: UserDefaultsClientable,
        keychainClient: KeychainClientable
    ) -> CampusClientStudySheet {

        let subject = CurrentValueSubject<State, Never>(.notLoading)

        return CampusClientStudySheet(
            subject: subject,
            load: {
                guard
                    let username = keychainClient.get(key: .campusUsername),
                    let password = keychainClient.get(key: .campusPassword)
                else {
                    subject.send(.notLoading)
                    return .none
                }
                let campusLoginQuery = CampusLoginQuery(
                    username: username,
                    password: password
                )
                subject.send(.loading)
                
                let task: Effect<[StudySheetItem], Error> = Effect.task {
                    let result = try await apiClient.decodedResponse(
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

    static func mock() -> CampusClientStudySheet {
        CampusClientStudySheet(
            subject: CurrentValueSubject<State, Never>(.notLoading),
            load: { .none },
            clean: { }
        )
    }

}
