//
//  SpinnerVC.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/2/24.
//

import UIKit

class SpinnerVC: UIViewController {

    var spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)

        spinner.color = .systemPurple
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
