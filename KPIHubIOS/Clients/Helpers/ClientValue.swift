//
//  ClientValue.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.06.2022.
//

import Foundation

/// Used for setting or updating values to clients with `CurrentValueSubject`'s
/// to delay setting its value and updating UI.
struct ClientValue<T> {
    let value: T
    let commitChanges: Bool

    init(_ value: T, commitChanges: Bool) {
        self.value = value
        self.commitChanges = commitChanges
    }
}
