//
//  UIApplication+endEditing.swift
//  KPIHubIOS
//
//  Created by Denys Danyliuk on 03.07.2022.
//

import SwiftUI

extension UIApplication {

    public func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
}
