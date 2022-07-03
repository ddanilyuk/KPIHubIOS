//
//  Loader.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI

struct Loader: View {

    @Environment(\.colorScheme) var colorScheme

    @State private var animatableParameter: Double = 0

    var body: some View {
        ZStack {

            colorScheme == .light ? Color.secondary.opacity(0.3) : Color.primary.opacity(0.3)

            ProgressView("Завантаження...")
                .foregroundColor(Color.orange)
                .font(.caption)
                .tint(Color.orange)
                .controlSize(.large)
                .scaleEffect(1.5)
                .progressViewStyle(.circular)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
}
