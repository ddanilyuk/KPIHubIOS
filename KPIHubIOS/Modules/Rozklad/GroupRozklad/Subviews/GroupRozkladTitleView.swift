//
//  GroupRozkladTitleView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 02.06.2022.
//

import SwiftUI

struct GroupRozkladTitleView: View {

    let title: String

    var body: some View {
        Text("\(title)")
            .foregroundColor(.white)
            .font(.system(.title2).bold())
            .frame(height: 40)
            .padding(.horizontal, 16)
            .background(
                Rectangle()
                    .fill(Color.orange)
                    .cornerRadius(8, corners: [.topRight, .bottomRight])
            )
            .shadow(color: .orange.opacity(0.4), radius: 4, x: 2, y: 0)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

private struct SafeAreaInsetsKey: EnvironmentKey {

    static var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }

    static var defaultValue: EdgeInsets {
        (keyWindow?.safeAreaInsets ?? .zero).insets
    }
}

extension EnvironmentValues {

    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {

    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}
