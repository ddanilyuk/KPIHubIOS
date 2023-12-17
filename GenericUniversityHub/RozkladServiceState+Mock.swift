//
//  RozkladServiceState+Mock.swift
//  GenericUniversityHub
//
//  Created by Denys Danyliuk on 17.12.2023.
//

import Services
import RozkladServices
import Foundation

extension RozkladServiceState {
    static func mock() -> RozkladServiceState {
        var rozkladServiceState = RozkladServiceState()
        rozkladServiceState.loadGroups = {
            try await Task.sleep(for: .seconds(3))
            return [
                GroupResponse(id: UUID(), name: "ІПЗ-11", faculty: "Географічний факультет"),
                GroupResponse(id: UUID(), name: "ІПЗ-12", faculty: "Географічний факультет"),
                GroupResponse(id: UUID(), name: "ІПЗ-13", faculty: "Географічний факультет"),
                GroupResponse(id: UUID(), name: "ІПЗ-14", faculty: "Географічний факультет"),
                GroupResponse(id: UUID(), name: "ІПЗ-15", faculty: "Географічний факультет"),
                GroupResponse(id: UUID(), name: "ІПЗ-16", faculty: "Географічний факультет"),
                GroupResponse(id: UUID(), name: "ЕПН-11", faculty: "Економічний факультет"),
                GroupResponse(id: UUID(), name: "ЕПН-12", faculty: "Економічний факультет"),
                GroupResponse(id: UUID(), name: "ЕПН-13", faculty: "Економічний факультет"),
                GroupResponse(id: UUID(), name: "ЕПН-14", faculty: "Економічний факультет"),
                GroupResponse(id: UUID(), name: "ЕПН-15", faculty: "Економічний факультет"),
                GroupResponse(id: UUID(), name: "МЕХ-11", faculty: "Механіко-математичний факультет"),
                GroupResponse(id: UUID(), name: "МЕХ-12", faculty: "Механіко-математичний факультет"),
                GroupResponse(id: UUID(), name: "МЕХ-13", faculty: "Механіко-математичний факультет"),
                GroupResponse(id: UUID(), name: "МЕХ-14", faculty: "Механіко-математичний факультет"),
                GroupResponse(id: UUID(), name: "МЕХ-15", faculty: "Механіко-математичний факультет"),
                GroupResponse(id: UUID(), name: "МЕХ-16", faculty: "Механіко-математичний факультет"),
                GroupResponse(id: UUID(), name: "МІТ-11", faculty: "Факультет інформаційних технологій"),
                GroupResponse(id: UUID(), name: "МІТ-12", faculty: "Факультет інформаційних технологій"),
                GroupResponse(id: UUID(), name: "МІТ-13", faculty: "Факультет інформаційних технологій"),
                GroupResponse(id: UUID(), name: "МІТ-14", faculty: "Факультет інформаційних технологій"),
                GroupResponse(id: UUID(), name: "МІТ-15", faculty: "Факультет інформаційних технологій"),
                GroupResponse(id: UUID(), name: "МІТ-16", faculty: "Факультет інформаційних технологій"),
            ]
        }
        return rozkladServiceState
    }
}
