//
//  CoordinatorSupport.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.05.2022.
//

import Foundation
import ComposableArchitecture
import TCACoordinators

protocol CoordinatorStateIdentifiable: Identifiable {

    static var module: Any.Type { get set }
}

extension CoordinatorStateIdentifiable {

    var id: String {
        let mirror = Mirror(reflecting: self)
        if let name = mirror.children.first?.label {
//            print("ID screen \(Self.module).\(name)")
            return "\(Self.module).\(name)"
        } else {
            assertionFailure("Invalid name")
            return UUID().uuidString
        }
    }

}

extension IdentifiedArray {

    func first<ScreenProviderState, SearchedState>(
        where casePath: CasePath<ScreenProviderState, SearchedState>
    ) -> SearchedState? where Element == Route<ScreenProviderState> {
        guard
            let screen = first(where: { casePath.extract(from: $0.screen) != nil })?.screen,
            let state = casePath.extract(from: screen)
        else {
            return nil
        }
        return state
    }

    func find<ScreenProviderState: Identifiable, SearchedState>(
        _ id: Element.ID,
        extract casePath: CasePath<ScreenProviderState, SearchedState>
    ) -> SearchedState? where Element == Route<ScreenProviderState>, ID == Element.ID {
        guard
            let screen = self[id: id]?.screen,
            let state = casePath.extract(from: screen)
        else {
            return nil
        }
        return state
    }

}
