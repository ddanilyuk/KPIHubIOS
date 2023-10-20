//
//  Theme.swift
//  
//
//  Created by Denys Danyliuk on 15.10.2023.
//

import Foundation
import SwiftUI

public struct Theme {
    public let screenBackgroundColor: Color
}

extension Theme {
    public static let `default`: Self = Self(
        screenBackgroundColor: Color(.screenBackground)
    )
}
