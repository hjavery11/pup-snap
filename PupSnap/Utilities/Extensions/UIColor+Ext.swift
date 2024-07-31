//
//  UIColor+Ext.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/31/24.
//

import UIKit
import SwiftUI

enum AppColors {
    static let appPurple = UIColor(red: 0.56, green: 0.35, blue: 1, alpha: 1)
}

//swiftUI
extension Color {
    static let appPurple = Color(AppColors.appPurple)
}
