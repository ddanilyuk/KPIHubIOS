//
//  LargeTagView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 01.06.2022.
//

import SwiftUI

struct LargeTagView: View {

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
                    .font(.system(.body))
                    .foregroundColor(.white)
            }
            .frame(width: 30, height: 30)

            Text("\(text)")
                .foregroundColor(.black)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
        }
        .background(color.lighter(by: colorScheme == .light ? 0.9 : 0.7))
        .cornerRadius(15)
        .if(colorScheme == .light) { view in
            view
                .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
        }
    }

}

// MARK: - Preview

struct LargeTagView_Previews: PreviewProvider {
    static var previews: some View {
        LargeTagView(
            icon: Image(systemName: "graduationcap"),
            text: "Практика",
            color: .cyan
        )
        .previewLayout(.fixed(width: 200, height: 100))
    }
}
