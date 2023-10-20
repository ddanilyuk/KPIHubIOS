//
//  LinearGradientAnimatableView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 24.06.2022.
//

import SwiftUI

struct LinearGradientAnimatableView: View {
    @State private var progress: CGFloat = 0

    let startGradient = Gradient(colors: [.purple, .yellow])
    let endGradient = Gradient(colors: [.blue, .purple])

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .animatableGradient(
                fromGradient: startGradient,
                toGradient: endGradient,
                progress: progress
            )
            .cornerRadius(2)
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: true)) {
                    self.progress = 1.0
                }
            }
    }
}

private struct AnimatableGradientModifier: AnimatableModifier {
    let fromGradient: Gradient
    let toGradient: Gradient
    var progress: CGFloat = 0.0

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func body(content: Content) -> some View {
        var gradientColors = [Color]()

        for index in 0..<fromGradient.stops.count {
            let fromColor = UIColor(fromGradient.stops[index].color)
            let toColor = UIColor(toGradient.stops[index].color)

            gradientColors.append(colorMixer(fromColor: fromColor, toColor: toColor, progress: progress))
        }

        return LinearGradient(
            gradient: Gradient(colors: gradientColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func colorMixer(fromColor: UIColor, toColor: UIColor, progress: CGFloat) -> Color {
        guard let fromColor = fromColor.cgColor.components else {
            return Color(fromColor)
        }
        guard let toColor = toColor.cgColor.components else {
            return Color(toColor)
        }

        let red = fromColor[0] + (toColor[0] - fromColor[0]) * progress
        let green = fromColor[1] + (toColor[1] - fromColor[1]) * progress
        let blue = fromColor[2] + (toColor[2] - fromColor[2]) * progress

        return Color(red: Double(red), green: Double(green), blue: Double(blue))
    }
}

private extension View {
    func animatableGradient(fromGradient: Gradient, toGradient: Gradient, progress: CGFloat) -> some View {
        self.modifier(AnimatableGradientModifier(fromGradient: fromGradient, toGradient: toGradient, progress: progress))
    }
}
