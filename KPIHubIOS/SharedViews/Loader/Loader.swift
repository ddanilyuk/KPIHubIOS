//
//  Loader.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI

struct Loader: View {

    @State private var animatableParameter: Double = 0

    var body: some View {
        ZStack {
            Color.secondary.opacity(0.3)

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
