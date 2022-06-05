//
//  Loader.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import SwiftUI

struct Loader: View {

    public var body: some View {
        ZStack(alignment: .center) {
            Color.secondary.opacity(0.3)

            GrowingArcIndicatorView(color: .orange, lineWidth: 4)
                .frame(width: 80, height: 80)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct GrowingArcIndicatorView: View {

    let color: Color
    let lineWidth: CGFloat

    @State private var animatableParameter: Double = 0

    public var body: some View {
        let animation = Animation
            .easeIn(duration: 1.5)
            .repeatForever(autoreverses: false)

        return GrowingArc(parameter: animatableParameter)
            .stroke(color, lineWidth: lineWidth)
            .onAppear {
                animatableParameter = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    withAnimation(animation) {
                        animatableParameter = 1
                    }
                }
            }
    }
}

struct GrowingArc: Shape {

    var maxLength = 2 * Double.pi - 0.7
    var lag = 0.35
    var parameter: Double

    var animatableData: Double {
        get {
            parameter
        }
        set {
            parameter = newValue
        }
    }

    func path(in rect: CGRect) -> Path {

        let hh = parameter * 2
        var length = hh * maxLength
        if hh > 1 && hh < lag + 1 {
            length = maxLength
        }
        if hh > lag + 1 {
            let coeff = 1 / (1 - lag)
            let n = hh - 1 - lag
            length = (1 - n * coeff) * maxLength
        }

        let first = Double.pi / 2
        let second = 4 * Double.pi - first

        var end = hh * first
        if hh > 1 {
            end = first + (hh - 1) * second
        }

        let start = end + length

        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.size.width / 2, y: rect.size.width / 2),
            radius: rect.size.width / 2,
            startAngle: Angle(radians: start),
            endAngle: Angle(radians: end),
            clockwise: true
        )
        return path
    }
}
