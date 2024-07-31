//
//  String+Ext.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/31/24.
//

import Foundation


extension String {
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
