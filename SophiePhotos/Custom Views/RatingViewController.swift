//
//  RatingView.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/5/24.
//

import UIKit

class RatingViewController: UIViewController {
    
    weak var lastClickedButton: UIButton?
    
    let starButtons: [UIButton] = {
        var buttons = [UIButton]()
        for _ in 1...5 {
           // var configuration = UIButton.Configuration.plain()
            let button = UIButton()
            button.setImage(UIImage(systemName: "dog", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .light)), for: .normal)
            button.setImage(UIImage(systemName: "dog.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .light)), for: .selected)
            button.tintColor = .systemPurple
            buttons.append(button)
        }
        return buttons
    }()
    
    var rating = 0 {
        didSet {
            updateStarSelectionStates()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupStarButtons()
    }

    
    
    func setupStarButtons() {
        let stackView = UIStackView(arrangedSubviews: starButtons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        
        for (index, button) in starButtons.enumerated() {
            button.tag = index + 1
            button.addTarget(self, action: #selector(starButtonTapped(_:)), for: .touchUpInside)
        }
        
        NSLayoutConstraint.activate([
                   stackView.topAnchor.constraint(equalTo: view.topAnchor),
                   stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                   stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
               ])
        
        updateStarSelectionStates()
    }
    
    @objc func starButtonTapped(_ button: UIButton) {
        if lastClickedButton == button && rating == button.tag { // Double-tap logic
            rating = 0
            lastClickedButton = nil // Reset last clicked button
        } else {
            rating = button.tag
            lastClickedButton = button
        }
    }
    
    func updateStarSelectionStates() {
        for (index, button) in starButtons.enumerated() {
            button.isSelected = index < rating
            button.backgroundColor = .clear // Ensure the background stays clear
        }
    }
}
