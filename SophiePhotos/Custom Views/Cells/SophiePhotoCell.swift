//
//  SophiePhotoCell.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/2/24.
//

import UIKit

class SophiePhotoCell: UICollectionViewCell {
    
    static let reuseID = "SophiePhotoCell"
    let thumbnailImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        addSubview(thumbnailImageView)
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.layoutIfNeeded()
        thumbnailImageView.layer.cornerRadius = 8
        thumbnailImageView.layer.masksToBounds = true
 
        
        
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    
    
    
    func set(image: UIImage) {
        thumbnailImageView.image = image
    }
}
