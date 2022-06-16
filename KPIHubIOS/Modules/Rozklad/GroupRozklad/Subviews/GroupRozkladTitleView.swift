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
            .frame(maxWidth: .infinity, alignment: .center)
            .font(.system(.title2).bold())
            .frame(height: 42)
    }
}
