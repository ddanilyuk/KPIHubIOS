//
//  RozkladSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 07.06.2022.
//

import SwiftUI

struct RozkladSectionView: View {

    let rozkladState: RozkladClient.State
    let onChangeGroup: () -> Void
    let onSelectGroup: () -> Void

    var body: some View {

        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)

            VStack(alignment: .leading, spacing: 20) {
                Text("Розклад")
                    .font(.system(.body).bold())

                switch rozkladState {
                case let .selected(group):
                    selectedView(with: group)
                case .notSelected:
                    notSelectedView
                }
            }
            .padding()
        }
    }

    func selectedView(with group: GroupResponse) -> some View {
        VStack(alignment: .leading, spacing: 20) {

            ProfileHomeViewCell(
                title: "Обрана группа:",
                value: .text(group.name),
                imageName: "person.2",
                backgroundColor: Color(red: 254 / 255, green: 251 / 255, blue: 232 / 255),
                accentColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
            )

            Divider()

            Button(
                action: { onChangeGroup() },
                label: {
                    Text("Змінити групу")
                        .font(.system(.body).bold())
                        .foregroundColor(.red)

                    Spacer()
                }
            )
        }
    }

    var notSelectedView: some View {
        VStack(alignment: .leading, spacing: 20) {

            Divider()

            Button(
                action: { onSelectGroup() },
                label: {
                    Text("Обрати групу")
                        .font(.system(.body).bold())
                        .foregroundColor(.green)

                    Spacer()
                }
            )
        }
    }

}
