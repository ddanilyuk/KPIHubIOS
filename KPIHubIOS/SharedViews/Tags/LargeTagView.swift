//
//  LargeTagView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 01.06.2022.
//

import SwiftUI

struct LargeTagView: View {

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
                    .font(.system(.body))
                    .foregroundColor(.white)
            }
            .frame(width: 30, height: 30)

            Text("\(text)")
                .font(.system(.body))
                .foregroundColor(.init(red: 37 / 255, green: 45 / 255, blue: 57 / 255))
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
        }
        .background(backgroundColor)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
    }

}

// MARK: - Preview

struct LargeTagView_Previews: PreviewProvider {
    static var previews: some View {
        LargeTagView(
            icon: Image(systemName: "graduationcap"),
            text: "Практика",
            backgroundColor: Color.cyan.lighter(by: 0.9),
            accentColor: Color.cyan
        )
        .previewLayout(.fixed(width: 200, height: 100))
    }
}
