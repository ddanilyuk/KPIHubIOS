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
