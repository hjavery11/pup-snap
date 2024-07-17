//
//  SettingsVC.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/15/24.
//

import UIKit
import SwiftUI

class SettingsVC: UIViewController {  
    
    var settingsView: UIHostingController<SettingsView>?
    var pairingKey: String?
 
    init(pairingKey: String? = nil) {
        self.pairingKey = pairingKey
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let viewModel = SettingsViewModel()
        let rootView = SettingsView(viewModel: viewModel, pairingKey: pairingKey)
        settingsView = UIHostingController(rootView: rootView)
        
        guard let settingsView = settingsView else { return }
        
        addChild(settingsView)
        view.addSubview(settingsView.view)
        settingsView.didMove(toParent: self)
        setupConstraints()
        
        
        
        
        
    }
    
    func setupConstraints() {
        settingsView?.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsView!.view.topAnchor.constraint(equalTo: view.topAnchor),
            settingsView!.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            settingsView!.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsView!.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }    
   
}
