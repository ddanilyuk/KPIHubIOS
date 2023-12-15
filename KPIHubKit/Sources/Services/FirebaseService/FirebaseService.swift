//
//  FirebaseService.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Foundation
@_exported import ComposableArchitecture

@DependencyClient
public struct FirebaseService {
    public var setup: (_ bundle: Bundle) -> Void
}
