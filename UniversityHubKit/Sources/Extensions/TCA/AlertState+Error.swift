//
//  AlertState+Error.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 30.06.2022.
//

import Foundation
import ComposableArchitecture

extension AlertState {
    public static func error(_ error: Error) -> Self {
        AlertState(
            title: TextState("Помилка"),
            message: TextState("\(error.localizedDescription)"),
            dismissButton: .default(TextState("Ok"))
        )
    }
}
