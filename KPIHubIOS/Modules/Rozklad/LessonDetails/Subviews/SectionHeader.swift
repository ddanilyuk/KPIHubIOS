//
//  SectionHeader.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

struct SectionHeader: View {

    var title: String

    var body: some View {
        Text(title)
            .font(.system(.subheadline).weight(.regular))
            .padding(.horizontal, 16)
            .frame(height: 25)
    }

}
