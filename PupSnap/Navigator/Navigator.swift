//
//  Navigator.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/26/24.
//

import UIKit

class Navigator {
    
    static let shared = Navigator()
    
    private init() {}
    
    var rootVC: UIViewController?
    var window: UIWindow?
    
    func pushVC(vc: UIViewController, animated: Bool) {
       
    }
    
    func dismissVC(vc: UIViewController, animated: Bool) {
        
    }
    
    func modalVC(vc: UIViewController, animated: Bool, presentationMode: UIModalPresentationStyle? = .automatic) {
        
    }
  
    
    
}
