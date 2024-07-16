//
//  UIImageView+Ext.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/4/24.
//

import UIKit

extension UIImageView {
    //extension to find the frame of the actual image inside the imageview without the negative space due to aspect ratio fit
    func imageFrame() -> CGRect? {
        guard let image = self.image else { return nil }

        let imageViewSize = self.bounds.size
        let imageSize = image.size

        let imageViewAspectRatio = imageViewSize.width / imageViewSize.height
        let imageAspectRatio = imageSize.width / imageSize.height

        var scaleFactor: CGFloat
        var scaledImageSize: CGSize
        var imageOrigin: CGPoint

        if imageAspectRatio > imageViewAspectRatio {
            // Image is wider than the view
            scaleFactor = imageViewSize.width / imageSize.width
            scaledImageSize = CGSize(width: imageViewSize.width, height: imageSize.height * scaleFactor)
            imageOrigin = CGPoint(x: 0, y: (imageViewSize.height - scaledImageSize.height) / 2)
        } else {
            // Image is taller than the view
            scaleFactor = imageViewSize.height / imageSize.height
            scaledImageSize = CGSize(width: imageSize.width * scaleFactor, height: imageViewSize.height)
            imageOrigin = CGPoint(x: (imageViewSize.width - scaledImageSize.width) / 2, y: 0)
        }

        return CGRect(origin: imageOrigin, size: scaledImageSize)
    }
}
