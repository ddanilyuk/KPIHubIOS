//
//  RozkladSectionView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 07.06.2022.
//

import SwiftUI

struct RozkladSectionView: View {

    let lessonsUpdatedDate: Date?
    let rozkladState: RozkladClient.StateModule.State
    let onUpdateRozklad: () -> Void
    let onChangeGroup: () -> Void
    let onSelectGroup: () -> Void

    var body: some View {
        ProfileSection(
            title: "Розклад",
            content: {
                switch rozkladState {
                case let .selected(group):
                    selectedView(with: group)
                case .notSelected:
                    notSelectedView
                }
            }
        )
    }

    func selectedView(with group: GroupResponse) -> some View {
        VStack(alignment: .leading, spacing: 20) {

            ProfileHomeViewCell(
                title: "Обрана группа:",
                value: .text(group.name),
                image: {
                    Image(systemName: "person.2")
                        .foregroundColor(Color(red: 254 / 255, green: 251 / 255, blue: 232 / 255))
                },
                backgroundColor: Color(red: 243 / 255, green: 209 / 255, blue: 19 / 255)
            )

            ProfileHomeViewCell(
                title: "Останнє оновлення:",
                value: .date(lessonsUpdatedDate),
                image: {
                    Image(systemName: "clock")
                        .foregroundColor(.indigo.lighter(by: 0.9))
                },
                backgroundColor: .indigo,
                rightView: {
                    Button(
                        action: { onUpdateRozklad() },
                        label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .foregroundColor(.red)
                                .font(.headline.bold())
                        }
                    )
                }
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

extension Color {
    public func lighter(by amount: CGFloat = 0.2) -> Self { Self(UIColor(self).lighter(by: amount)) }
    public func darker(by amount: CGFloat = 0.2) -> Self { Self(UIColor(self).darker(by: amount)) }
}

extension UIColor {
    func mix(with color: UIColor, amount: CGFloat) -> Self {
        var red1: CGFloat = 0
        var green1: CGFloat = 0
        var blue1: CGFloat = 0
        var alpha1: CGFloat = 0

        var red2: CGFloat = 0
        var green2: CGFloat = 0
        var blue2: CGFloat = 0
        var alpha2: CGFloat = 0

        getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)

        return Self(
            red: red1 * CGFloat(1.0 - amount) + red2 * amount,
            green: green1 * CGFloat(1.0 - amount) + green2 * amount,
            blue: blue1 * CGFloat(1.0 - amount) + blue2 * amount,
            alpha: alpha1
        )
    }

    func lighter(by amount: CGFloat = 0.2) -> Self { mix(with: .white, amount: amount) }
    func darker(by amount: CGFloat = 0.2) -> Self { mix(with: .black, amount: amount) }
}
