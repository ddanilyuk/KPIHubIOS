//
//  Collection+Safe.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

extension Array where Element == String {
    var isContentEmpty: Bool {
        self
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined()
            .isEmpty
    }
}
