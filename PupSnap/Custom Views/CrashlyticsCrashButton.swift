//
//  CrashlyticsCrashButton.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/4/24.
//

import UIKit

class CrashlyticsCrashButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    private func setupButton() {
        self.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
        self.setTitle("Test Crash", for: .normal)
        self.addTarget(self, action: #selector(crashButtonTapped(_:)), for: .touchUpInside)
        self.backgroundColor = .systemBlue
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 5
    }

    @objc private func crashButtonTapped(_ sender: AnyObject) {
        let numbers = [0]
         _ = numbers[1] // This will crash
    }
}
