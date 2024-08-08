//
//  UIApplication+Ext.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/16/24.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

