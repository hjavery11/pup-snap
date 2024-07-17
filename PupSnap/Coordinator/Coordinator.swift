//
//  Coordinator.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/16/24.
//

import UIKit


protocol Coordinator {
    var children: [Coordinator] { get set }
    var nav: UINavigationController { get set }
    
    func start()
}
