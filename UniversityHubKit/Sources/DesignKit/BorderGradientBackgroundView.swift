//
//  BorderGradientBackgroundView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import SwiftUI
import Extensions

public struct BorderGradientBackgroundView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var gradientAngle: Double = 0
    
    public init() { }

    public var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                colorScheme == .light ? Color.white : Color(.tertiarySystemFill),
                strokeBorder: AngularGradient(
                    gradient: Gradient(colors: [
                        .red.opacity(0.7),
                        .orange.opacity(0.7),
                        .purple.opacity(0.7),
                        .yellow.opacity(0.7),
                        .red.opacity(0.7)
                    ]),
                    center: .center,
                    angle: .degrees(gradientAngle)
                ),
                lineWidth: 2
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
                    self.gradientAngle = 360
                }
            }
    }
}
