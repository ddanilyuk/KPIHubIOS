//
//  LessonDetailsLocationsSection.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

struct LessonDetailsLocationsSection: View {

    var locations: [String]

    var body: some View {
        LessonDetailsSectionView(
            title: "Локація",
            content: { content }
        )
    }

    var content: some View {
        VStack(spacing: 16) {
            ForEach(locations, id: \.self) { location in
                VStack(spacing: 16) {
                    HStack(spacing: 0) {
                        LargeTagView(
                            icon: Image(systemName: "location"),
                            text: location,
                            color: .yellow
                        )

                        Spacer()
                    }
                    // If you add a separator, then text wrapping and layout will break
                    // if teacher != teachers.last {
                    //    Divider()
                    // }
                }
            }
        }
        .padding(16)
    }

}
