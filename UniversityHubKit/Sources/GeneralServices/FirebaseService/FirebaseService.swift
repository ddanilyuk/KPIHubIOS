//
//  FirebaseService.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 18.09.2022.
//

import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
public struct FirebaseService {
    public var setup: (_ bundle: Bundle) -> Void
}
