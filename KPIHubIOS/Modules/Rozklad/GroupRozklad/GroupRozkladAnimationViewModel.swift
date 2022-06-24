//
//  GroupRozkladAnimationViewModel.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 16.06.2022.
//

import SwiftUI

final class GroupRozkladAnimationViewModel: ObservableObject {

    // MARK: - LastShownElement

    struct LastShownElement {
        var index: Int
        var value: CGFloat
    }

    // MARK: - Public properties

    @Published var position = GroupRozklad.State.Section.Position(week: .first, day: .monday)
    var lastShownElement: LastShownElement?
    var targetSize: CGFloat = 0

    // MARK: - Private properties

    private var renderedPosition = GroupRozklad.State.Section.Position(week: .first, day: .monday)
    private var offsets: [CGFloat?] = Array(
        repeating: nil,
        count: GroupRozklad.State.Section.Position.count
    )
    private var savedOffsets: [CGFloat?] = Array(
        repeating: nil,
        count: GroupRozklad.State.Section.Position.count
    )

    init() {
//        super.init()

        print("INIT")
    }

    // MARK: - Public methods

    func save() {
        savedOffsets = offsets
    }

    func restore() {
        offsets = savedOffsets
        render()
    }

    func setOffset(for index: Int, value: CGFloat?) {
        if offsets[index] == value {
            return
        }
        offsets[index] = value
        render()
    }
    
    // MARK: - Private methods

    private func render() {
        DispatchQueue.global(qos: .userInteractive).async { [self] in
            let newPosition = GroupRozklad.State.Section.Position(
                index: min(max(0, calculateIndex()), 11)
            )
            if newPosition != renderedPosition {
                DispatchQueue.main.async { [self] in
                    position = newPosition
                }
            }
            renderedPosition = newPosition
        }
    }

    private func debug() {
        let debug = offsets.map { optionalFloat in
            if let float = optionalFloat {
                return "\(float.rounded())"
            } else {
                return "nil"
            }
        }
        .joined(separator: " | ")
        print(debug)
    }

    private func calculateIndex() -> Int {
        let target: CGFloat = targetSize + 1
//        print(target)
        let offsets = offsets
        let numberOfElements = offsets.compactMap { $0 }.count

        func compareWithTarget(element: CGFloat, index: Int) -> Int {
            element < target ? index : index - 1
        }

        switch numberOfElements {
        case 1:
            let index = offsets.firstIndex(where: { $0 != nil })!
            let element = offsets[index]!
            lastShownElement = LastShownElement(index: index, value: element)
            return compareWithTarget(element: element, index: index)

        case 0:
            guard let lastShownElement = lastShownElement else {
                return 0
            }
            return compareWithTarget(element: lastShownElement.value, index: lastShownElement.index)

        default:
            let index = offsets.firstIndex(where: { $0 != nil })!
            let element = offsets[index]!
            if element < target {
                return offsets.lastIndex(where: { $0 != nil ? $0! < target : false }) ?? index
            } else {
                return index - 1
            }
        }
    }

}
