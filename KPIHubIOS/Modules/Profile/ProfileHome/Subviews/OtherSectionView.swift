//
//  OtherSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 23.06.2022.
//

import SwiftUI

struct OtherSectionView: View {

    let forDevelopers: () -> Void

    var body: some View {
        ProfileSection(
            title: "Інше",
            content: {
                ProfileHomeViewCell(
                    title: "",
                    value: .text("Для розробників"),
                    image: {
                        Image(systemName: "terminal")
                            .foregroundColor(.red.lighter(by: 0.9))
                    },
                    backgroundColor: .red
                )
                .onTapGesture {
                    forDevelopers()
                }
            }
        )
    }
}