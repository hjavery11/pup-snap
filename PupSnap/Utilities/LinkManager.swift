//
//  LinkManager.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/16/24.
//

import UIKit

class LinkManager {
    static let shared = LinkManager()
    var params: [String: AnyObject]?
    
    private init() {}
    
    func handleDeepLink() {
        print("Handling deep link for \(String(describing: params))")
    }
    
}
