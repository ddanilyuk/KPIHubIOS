//
//  Loader.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI

struct Loader: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.designKit) var designKit
    
    var body: some View {
        ZStack {
            colorScheme == .light ? Color.secondary.opacity(0.3) : Color.primary.opacity(0.3)

            ProgressView("Завантаження...")
                .foregroundColor(designKit.primaryColor)
                .font(.caption)
                .tint(designKit.primaryColor)
                .controlSize(.extraLarge)
                .progressViewStyle(.circular)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
