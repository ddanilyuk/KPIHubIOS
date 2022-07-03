//
//  SmallTagView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 31.05.2022.
//

import SwiftUI

struct SmallTagView: View {

    @Environment(\.colorScheme) var colorScheme

    let icon: Image
    let text: String
    let color: Color

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ZStack {
                Circle()
                    .fill(color)

                icon
                    .font(.system(.footnote))
                    .foregroundColor(.white)
            }
            .frame(width: 24, height: 24)

            Text("\(text)")
                .lineLimit(1)
                .font(.system(.footnote))
                .foregroundColor(.black)
                .padding(.vertical, 3)
                .padding(.horizontal, 6)
        }
        .background(color.lighter(by: colorScheme == .light ? 0.9 : 0.7))
        .cornerRadius(12)
    }

}


// MARK: - Preview

struct SmallTagView_Previews: PreviewProvider {
    static var previews: some View {
        SmallTagView(
            icon: Image(systemName: "graduationcap"),
            text: "Практика",
            color: .cyan
        )
        .previewLayout(.fixed(width: 200, height: 100))
    }
}
