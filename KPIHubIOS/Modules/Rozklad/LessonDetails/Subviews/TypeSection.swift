//
//  TypeSection.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

struct TypeSection: View {

    var type: String

    var body: some View {

        VStack(alignment: .leading, spacing: 0) {
            SectionHeader(title: "Тип")

            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)

                HStack {
                    LargeTagView(
                        icon: Image(systemName: "graduationcap"),
                        text: type,
                        backgroundColor: Color(red: 237 / 255, green: 246 / 255, blue: 254 / 255),
                        accentColor: Color(red: 37 / 255, green: 114 / 255, blue: 228 / 255)
                    )
                    Spacer()
                }
                .padding(16)
            }
        }
    }

}
