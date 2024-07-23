//
//  SettingsVC.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/15/24.
//

import UIKit
import SwiftUI

class SettingsVC: UIViewController {
    
    let settingsView = UIHostingController(rootView: SettingsView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true

        
        addChild(settingsView)
        view.addSubview(settingsView.view)
        settingsView.didMove(toParent: self)
        setupConstraints()
    }
    
    func setupConstraints() {
        settingsView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsView.view.topAnchor.constraint(equalTo: view.topAnchor),
            settingsView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            settingsView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }    
    
    func tabSelected() {
        //settings tab selected
    }
   
}




