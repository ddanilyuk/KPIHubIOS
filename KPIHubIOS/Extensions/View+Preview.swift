//
//  View+Preview.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import SwiftUI

extension View {

    var smallPreview: some View {
        self
            .previewLayout(.sizeThatFits)
            .fixedSize(horizontal: false, vertical: true)
            .frame(width: 375)
    }
}
