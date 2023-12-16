//
//  EditingView.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 06.06.2022.
//

import SwiftUI

public struct EditingView: View {
    @Environment(\.designKit) var designKit
    
    public init() { }
    
    public var body: some View {
        Image(systemName: "pencil.circle.fill")
            .font(.system(size: 25))
            .foregroundColor(designKit.primaryColor)
    }
}
