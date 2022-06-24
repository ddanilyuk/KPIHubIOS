//
//  View+If.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 16.06.2022.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
