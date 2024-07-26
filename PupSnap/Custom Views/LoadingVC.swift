//
//  LoadingVC.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/17/24.
//

import UIKit

class LoadingVC: UIViewController {

    var spinner = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
  
        spinner.color = .systemPurple
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.dismiss(animated: false)
    }
    
    func configureMessage() {
        let text = UILabel()
        view.addSubview(text)
        
        text.text = "Please wait while we setup the app for you..."
        text.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.textColor = .label
        text.textAlignment = .center
        text.numberOfLines = 3
        
       
        
        NSLayoutConstraint.activate([
            text.widthAnchor.constraint(equalToConstant: 180),
            text.heightAnchor.constraint(equalToConstant: 130),
            text.bottomAnchor.constraint(equalTo: spinner.topAnchor, constant: -50),
            text.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
