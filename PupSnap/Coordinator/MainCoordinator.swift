//
//  MainCoordinator.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/16/24.
//

import UIKit

class MainCoordinator: Coordinator {
    var children: [any Coordinator] = []
    
    var nav: UINavigationController
    
    init(children: [any Coordinator], nav: UINavigationController) {
        self.children = children
        self.nav = nav
    }
    
    func start() {
        let vc = PhotoVC()
        nav.pushViewController(vc, animated: false)
    }
    
    
}
