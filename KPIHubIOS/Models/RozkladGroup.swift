//
//  RozkladGroup.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 29.05.2022.
//

import Foundation

struct RozkladGroup {

    let id: UUID
    let name: String

    let groupResponse: GroupResponse
}

extension RozkladGroup: Equatable {

}

extension RozkladGroup: Identifiable {

}

extension RozkladGroup {

    init(groupResponse: GroupResponse) {
        self.id = groupResponse.id
        self.name = groupResponse.name

        self.groupResponse = groupResponse
    }

}
