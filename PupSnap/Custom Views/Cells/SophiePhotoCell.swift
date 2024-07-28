//
//  SophiePhotoCell.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/2/24.
//

import UIKit
import FirebaseStorage
import FirebaseStorageUI

class SophiePhotoCell: UICollectionViewCell {

    static let reuseID = "SophiePhotoCell"
    var photo: Photo?
    var thumbnailImageView = UIImageView()
    // Create a storage reference from our storage service
    let storageRef: StorageReference
    
    override init(frame: CGRect) {
        // Get a reference to the storage service
        storageRef = Storage.storage().reference().child("images")
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

    func set(photo: Photo) {
        let userKey = PersistenceManager.retrieveKey()
        self.photo = photo
        let reference = self.storageRef.child(String(userKey)).child(photo.id + ".jpg")
        
        thumbnailImageView.sd_imageIndicator = SDWebImageProgressIndicator.bar
    
        thumbnailImageView.sd_setImage(with: reference, placeholderImage: UIImage(named: "placeholder_image"))
        

    
    }
}
