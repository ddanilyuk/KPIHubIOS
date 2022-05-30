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
                .padding(.vertical, 3)
                .padding(.horizontal, 6)
        }
        .background(backgroundColor)
        .cornerRadius(12)
    }

}


// MARK: - Preview

struct SmallTagView_Previews: PreviewProvider {
    static var previews: some View {
        SmallTagView(
            icon: Image(systemName: "graduationcap"),
            text: "Практика",
            backgroundColor: Color(red: 237 / 255, green: 246 / 255, blue: 254 / 255),
            accentColor: Color(red: 37 / 255, green: 114 / 255, blue: 228 / 255)
        )
        .previewLayout(.fixed(width: 200, height: 100))
    }
}
