//
//  CampusClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import Routes
import ComposableArchitecture
import KeychainAccess

struct CampusClientable {

    let state: CampusClientableState
    let studySheet: CampusClientableStudySheet

    static func live(
        apiClient: APIClient,
        userDefaultsClient: UserDefaultsClientable,
        keychainClient: KeychainClientable
    ) -> CampusClientable {
        CampusClientable(
            state: .live(
                userDefaultsClient: userDefaultsClient,
                keychainClient: keychainClient
            ),
            studySheet: .live(
                apiClient: apiClient,
                userDefaultsClient: userDefaultsClient,
                keychainClient: keychainClient
            )
        )
    }

    static func mock() -> CampusClientable {
        CampusClientable(
            state: .mock(),
            studySheet: .mock()
        )
    }

}

struct CampusClientableState {

    enum State: Equatable {
        case loggedIn(CampusUserInfo)
        case loggedOut
    }

    struct LoginRequest {
        let credentials: CampusCredentials
        let userInfo: CampusUserInfo
    }

    let subject: CurrentValueSubject<State, Never>

    let login: (ClientValue<LoginRequest>) -> Void
    let logout: (ClientValue<Void>) -> Void
    let commit: () -> Void

    static func live(
        userDefaultsClient: UserDefaultsClientable,
        keychainClient: KeychainClientable
    ) -> CampusClientableState {
        let subject = CurrentValueSubject<State, Never>(.loggedOut)
        let commit: () -> Void = {
            if let campusUserInfo = userDefaultsClient.get(for: .campusUserInfo) {
                subject.value = .loggedIn(campusUserInfo)
            } else {
                subject.value = .loggedOut
            }
        }
        commit()
        return CampusClientableState(
            subject: subject,
            login: { clientValue in
                let userInfo = clientValue.value.userInfo
                let credentials = clientValue.value.credentials
                userDefaultsClient.set(userInfo, for: .campusUserInfo)
                keychainClient.set(credentials.username, for: .campusUsername)
                keychainClient.set(credentials.password, for: .campusPassword)
                if clientValue.commitChanges {
                    commit()
                }
            },
            logout: { clientValue in
                userDefaultsClient.remove(for: .campusUserInfo)
                try? keychainClient.remove(for: .campusUsername)
                try? keychainClient.remove(for: .campusPassword)
                if clientValue.commitChanges {
                    commit()
                }
            },
            commit: commit
        )
    }

    static func mock() -> CampusClientableState {
        return CampusClientableState(
            subject: CurrentValueSubject<State, Never>(
                .loggedIn(CampusUserInfo.mock)
            ),
            login: { _ in },
            logout: { _ in },
            commit: { }
        )
    }

}

struct CampusClientableStudySheet {

    enum State: Equatable {
        case notLoading
        case loading
        case loaded([StudySheetItem])

        var desc: String {
            switch self {
            case .notLoading:
                return "notLoading"
            case .loading:
                return "loading"
            case .loaded:
                return "loaded"
            }
        }
    }

    let subject: CurrentValueSubject<State, Never>

    let load: () -> Effect<Void, Never>
    let clean: () -> Void

    static func live(
        apiClient: APIClient,
        userDefaultsClient: UserDefaultsClientable,
        keychainClient: KeychainClientable
    ) -> CampusClientableStudySheet {

        let subject = CurrentValueSubject<State, Never>(.notLoading)

        return CampusClientableStudySheet(
            subject: subject,
            load: {
                print("!!! START LOAD")
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
                print("!!! subject.send(.loading)r")
                let task: Effect<[StudySheetItem], Error> = Effect.task {
                    let result = try await apiClient.decodedResponse(
                        for: .api(.campus(.studySheet(campusLoginQuery))),
                        as: StudySheetResponse.self
                    )
                    print("!!! RESPONSE \(result.response.description)")
                    return result.value.studySheet.map { StudySheetItem(studySheetItemResponse: $0) }
                }
                return task
                    .on(
                        value: { print("!!! ON VALUE"); subject.send(.loaded($0)) },
                        error: { _ in print("!!! ON ERROR"); subject.send(.notLoading) }
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

    static func mock() -> CampusClientableStudySheet {
        CampusClientableStudySheet(
            subject: CurrentValueSubject<State, Never>(.notLoading),
            load: { .none },
            clean: { }
        )
    }

}

/*
final class CampusClient {

    // MARK: - State

    final class StateModule {

        enum State: Equatable {
            case loggedIn(CampusUserInfo)
            case loggedOut
        }

        private let userDefaultsClient: UserDefaultsClientable
        private let keychainClient: KeychainClientable

        lazy var subject: CurrentValueSubject<State, Never> = {
            if let campusUserInfo = userDefaultsClient.get(for: .campusUserInfo) {
                return .init(.loggedIn(campusUserInfo))
            } else {
                return .init(.loggedOut)
            }
        }()

        init(
            userDefaultsClient: UserDefaultsClientable,
            keychainClient: KeychainClientable
        ) {
            self.userDefaultsClient = userDefaultsClient
            self.keychainClient = keychainClient
        }

        func login(
            credentials: CampusCredentials,
            userInfo: CampusUserInfo,
            commitChanges: Bool
        ) {
            userDefaultsClient.set(userInfo, for: .campusUserInfo)
            keychainClient.set(credentials.username, for: .campusUsername)
            keychainClient.set(credentials.password, for: .campusPassword)
            if commitChanges {
                commit()
            }
        }

        func logOut(commitChanges: Bool) {
            userDefaultsClient.remove(for: .campusUserInfo)
            try? keychainClient.remove(for: .campusUsername)
            try? keychainClient.remove(for: .campusPassword)
            if commitChanges {
                commit()
            }
        }

        func commit() {
            if let campusUserInfo = userDefaultsClient.get(for: .campusUserInfo) {
                subject.send(.loggedIn(campusUserInfo))
            } else {
                subject.send(.loggedOut)
            }
        }
    }

    var state: StateModule

    // MARK: - StudySheet

    final class StudySheetModule {

        enum State: Equatable {
            case notLoading
            case loading
            case loaded([StudySheetItem])
        }

        private let userDefaultsClient: UserDefaultsClientable
        private let keychainClient: KeychainClientable
        private let apiClient: APIClient
        private var studySheetCancellable: Cancellable?

        var subject: CurrentValueSubject<State, Never> = .init(.notLoading)

        init(
            apiClient: APIClient,
            userDefaultsClient: UserDefaultsClientable,
            keychainClient: KeychainClientable
        ) {
            self.apiClient = apiClient
            self.userDefaultsClient = userDefaultsClient
            self.keychainClient = keychainClient
        }

        func load() {
            guard
                let username = keychainClient.get(key: .campusUsername),
                let password = keychainClient.get(key: .campusPassword)
            else {
                subject.send(.notLoading)
                return
            }
            let campusLoginQuery = CampusLoginQuery(
                username: username,
                password: password
            )
            let task: Effect<[StudySheetItem], Error> = Effect.task { [weak self] in
                guard let self = self else {
                    throw APIError.unknown
                }
                let result = try await self.apiClient.decodedResponse(
                    for: .api(.campus(.studySheet(campusLoginQuery))),
                    as: StudySheetResponse.self
                )
                return result.value.studySheet.map { StudySheetItem(studySheetItemResponse: $0) }
            }
            subject.send(.loading)
            studySheetCancellable?.cancel()
            studySheetCancellable = task.sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        return
                    case .failure:
                        self?.subject.send(.notLoading)
                    }
                },
                receiveValue: { [weak self] value in
                    self?.subject.send(.loaded(value))
                }
            )
        }

        func removeLoaded() {
            studySheetCancellable?.cancel()
            subject.send(.notLoading)
        }

    }

    var studySheet: StudySheetModule

    // MARK: - Lifecycle

    static func live(
        apiClient: APIClient,
        userDefaultsClient: UserDefaultsClientable,
        keychainClient: KeychainClientable
    ) -> CampusClient {
        CampusClient(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient,
            keychainClient: keychainClient
        )
    }

    static func mock(
        apiClient: APIClient = .failing,
        userDefaultsClient: UserDefaultsClientable = mockDependencies.userDefaults,
        keychainClient: KeychainClient = .mock()
    ) -> CampusClient {
        CampusClient(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient,
            keychainClient: keychainClient
        )
    }

    private init(
        apiClient: APIClient,
        userDefaultsClient: UserDefaultsClientable,
        keychainClient: KeychainClientable
    ) {
        self.state = StateModule(
            userDefaultsClient: userDefaultsClient,
            keychainClient: keychainClient
        )
        self.studySheet = StudySheetModule(
            apiClient: apiClient,
            userDefaultsClient: userDefaultsClient,
            keychainClient: keychainClient
        )
    }

}
*/
