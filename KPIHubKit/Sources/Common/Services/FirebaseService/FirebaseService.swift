//
//  FirebaseService.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
@_exported import ComposableArchitecture

@DependencyClient
struct FirebaseService {
    var setup: () -> Void
}
