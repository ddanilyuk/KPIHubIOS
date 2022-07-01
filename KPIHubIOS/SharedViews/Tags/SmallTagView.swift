//
//  SmallTagView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 31.05.2022.
//

import SwiftUI

struct SmallTagView: View {

    let icon: Image
    let text: String
    let backgroundColor: Color
    let accentColor: Color

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ZStack {
                Circle()
                    .fill(accentColor)

                icon
                    .font(.system(.footnote))
                    .foregroundColor(.white)
            }
            .frame(width: 24, height: 24)

            Text("\(text)")
                .font(.system(.footnote))
                .foregroundColor(.init(red: 37 / 255, green: 45 / 255, blue: 57 / 255))
                .padding(.vertical, 3)
                .padding(.horizontal, 6)
        }
        .background(backgroundColor)
        .cornerRadius(12)
//        .shadow(radius: 4)
//        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
    }

}


// MARK: - Preview

struct SmallTagView_Previews: PreviewProvider {
    static var previews: some View {
        SmallTagView(
            icon: Image(systemName: "graduationcap"),
            text: "Практика",
            backgroundColor: Color.cyan.lighter(by: 0.9),
            accentColor: Color.cyan
        )
        .previewLayout(.fixed(width: 200, height: 100))
    }
}
