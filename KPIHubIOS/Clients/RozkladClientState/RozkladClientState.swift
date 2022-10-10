//
//  RozkladClient.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 05.06.2022.
//

import Combine
import IdentifiedCollections
import Foundation
import CasePaths
import Dependencies


private enum RozkladClientStateV2Key: TestDependencyKey {
    static let testValue = RozkladClientStateV2.live(
        userDefaultsClient: DependencyValues._current.userDefaultsClient
    )
}

extension RozkladClientStateV2Key: DependencyKey {
    static let liveValue = RozkladClientStateV2.live(
        userDefaultsClient: DependencyValues._current.userDefaultsClient
    )
}

extension DependencyValues {
    var rozkladClientStateV2: RozkladClientStateV2 {
        get { self[RozkladClientStateV2Key.self] }
        set { self[RozkladClientStateV2Key.self] = newValue }
    }
}

struct RozkladClientStateV2 {

    enum State: Equatable, Sendable {
        case selected(GroupResponse)
        case notSelected
        
        init(_ group: GroupResponse?) {
            switch group {
            case let .some(groupResponse):
                self = .selected(groupResponse)
            case .none:
                self = .notSelected
            }
        }
    }

//    let subject: CurrentValueSubject<State, Never>
    private(set) var state: () -> State
    
    var observer: @Sendable () async -> AsyncStream<State>

//    @Sendable () async throws -> Void
    let group: () -> GroupResponse?
    let setState: (ClientValue<State>) -> Void
//    let commit: () -> Void
    

    static func live(userDefaultsClient: UserDefaultsClientable) -> RozkladClientStateV2 {
        print("---- live created")
//        var state = State.notSelected
//        let subject = CurrentValueSubject<State, Never>(.notSelected)
//        let commit: () -> Void = {
//            if let group = userDefaultsClient.get(for: .groupResponse) {
//                subject.send(.selected(group))
//            } else {
//                subject.send(.notSelected)
//            }
//        }
//        commit()
//        var cont: AsyncStream<RozkladClientStateV2.State>.Continuation!
        
        var updateStream: ((State) -> Void)?
        var group = userDefaultsClient.get(for: .groupResponse)
        print(group)
        var state = State(group)

        let stream: AsyncStream<State> = AsyncStream { continuation in
//            cont = continuation
            updateStream = { state in
                print("!!! Update stream here \(continuation)")
                continuation.yield(state)
                print("!!! Update stream after")
            }
        }

        return RozkladClientStateV2(
            state: { state },
            observer: { stream },
            group: {
                userDefaultsClient.get(for: .groupResponse)
            },
            setState: { clientValue in
                print("!!! Set state \(clientValue.value)")

                switch clientValue.value {
                case let .selected(group):
                    userDefaultsClient.set(group, for: .groupResponse)
                case .notSelected:
                    userDefaultsClient.remove(for: .groupResponse)
                }
                state = clientValue.value
                updateStream?(clientValue.value)
                print("!!! All passed \(clientValue.value)")

                if clientValue.commitChanges {
//                    commit()
                }
            }
//            commit: { }
        )
    }

//    static func mock() -> RozkladClientStateV2 {
//        let group = GroupResponse(id: UUID(), name: "ІВ-82", faculty: "ФІОТ")
//        return RozkladClientStateV2(
//            subject: CurrentValueSubject<State, Never>(
//                .selected(group)
//            ),
//            group: { group },
//            setState: { _ in },
//            commit: { }
//        )
//    }

}



private enum RozkladClientStateKey: TestDependencyKey {
    static let testValue = RozkladClientState.mock()
}

extension RozkladClientStateKey: DependencyKey {
    static let liveValue = RozkladClientState.live(
        userDefaultsClient: DependencyValues._current.userDefaultsClient
    )
}

extension DependencyValues {
    var rozkladClientState: RozkladClientState {
        get { self[RozkladClientStateKey.self] }
        set { self[RozkladClientStateKey.self] = newValue }
    }
}

struct RozkladClientState {

    enum State: Equatable {
        case selected(GroupResponse)
        case notSelected
    }

    let subject: CurrentValueSubject<State, Never>
    let group: () -> GroupResponse?
    let setState: (ClientValue<State>) -> Void
    let commit: () -> Void
    
    static func live(userDefaultsClient: UserDefaultsClientable) -> RozkladClientState {

        let subject = CurrentValueSubject<State, Never>(.notSelected)
        let commit: () -> Void = {
            if let group = userDefaultsClient.get(for: .groupResponse) {
                subject.send(.selected(group))
            } else {
                subject.send(.notSelected)
            }
        }
        commit()

        return RozkladClientState(
            subject: subject,
            group: {
                let groupResponsePath = /RozkladClientState.State.selected
                return groupResponsePath.extract(from: subject.value)
            },
            setState: { clientValue in
                switch clientValue.value {
                case let .selected(group):
                    userDefaultsClient.set(group, for: .groupResponse)
                case .notSelected:
                    userDefaultsClient.remove(for: .groupResponse)
                }
                if clientValue.commitChanges {
                    commit()
                }
            },
            commit: commit
        )
    }

    static func mock() -> RozkladClientState {
        let group = GroupResponse(id: UUID(), name: "ІВ-82", faculty: "ФІОТ")
        return RozkladClientState(
            subject: CurrentValueSubject<State, Never>(
                .selected(group)
            ),
            group: { group },
            setState: { _ in },
            commit: { }
        )
    }

}
