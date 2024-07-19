//
//  NotificationPhotoVC.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/19/24.
//

import UIKit

class NotificationPhotoVC: UIViewController {
    
    private var imageView: UIImageView
    var captionView = UILabel()
    
    init(imageView: UIImageView, caption: String) {
        self.imageView = imageView
        captionView.text = caption
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        setupImageView()
        configureCaptionView()
    }
    
    private func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
    }
    
    func configureCaptionView() {
        view.addSubview(captionView)
        captionView.translatesAutoresizingMaskIntoConstraints = false
        captionView.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .headline), size: 24)
        captionView.textColor = .label
        
        
        NSLayoutConstraint.activate([
            captionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            captionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
        ])
    }
}
