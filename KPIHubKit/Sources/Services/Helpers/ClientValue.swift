//
//  ClientValue.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.06.2022.
//

import Foundation

/// Used for setting or updating values to clients with `CurrentValueSubject`'s
/// to delay setting its value and updating UI.
public struct ClientValue<T> {
    public let value: T
    public let commitChanges: Bool

    public init(_ value: T, commitChanges: Bool) {
        self.value = value
        self.commitChanges = commitChanges
    }

    public init(commitChanges: Bool) where T == Void {
        self.value = ()
        self.commitChanges = commitChanges
    }
}
