//
//  FullScreenPhotoVC.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/2/24.
//

import UIKit

protocol FullScreenPhotoVCDelegate: AnyObject {
    func didSwipeImage(in viewController: FullScreenPhotoVC, to direction: UISwipeGestureRecognizer.Direction)
}


class FullScreenPhotoVC: UIViewController {

    
    weak var delegate: FullScreenPhotoVCDelegate?
    var activityIndicator = UIActivityIndicatorView(style: .large)
    var closeButton = UIButton()
    var imageView = UIImageView()
    
    init(image: UIImage) {
        super.init(nibName: nil, bundle: nil)
        imageView.image = image
    }
    
    init(url: String) {
        super.init(nibName: nil, bundle: nil)
        fetchImage(url: url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fetchImage(url: String) {
        //start loading
        activityIndicator.startAnimating()
        
       
            NetworkManager.shared.getPhoto(url) { [weak self] image in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    //stop loading
                    self.activityIndicator.stopAnimating()
                    
                    if let image = image {
                        self.imageView.image = image
                    } else {
                        print("Failed to fetch image")
                    }
                }
            }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        addGestures()
       
    }
    
    func addGestures() {
        let leftGesture = UISwipeGestureRecognizer(target: self , action: #selector(self.userDidSwipe))
        leftGesture.direction = [.left]
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.userDidSwipe))
        rightGesture.direction = [.right]
        self.view.addGestureRecognizer(leftGesture)
        self.view.addGestureRecognizer(rightGesture)
    }
    
    private func configure() {
        view.backgroundColor = .black
       
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
//        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
//        closeButton.tintColor = .white
//        closeButton.translatesAutoresizingMaskIntoConstraints = false
//        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
//        view.addSubview(closeButton)
//        
//        NSLayoutConstraint.activate([
//            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
//            closeButton.heightAnchor.constraint(equalToConstant: 40),
//            closeButton.widthAnchor.constraint(equalToConstant: 40)
//        ])
        
        
        setupLoading()
    }
    
    func setupLoading() {
        //configure loading spinner
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
//    @objc func closeButtonTapped() {
//        self.dismiss(animated: true) {
//            self.delegate?.didDismissFullScreenPhotoVC()
//        }
//    }
    
    @objc func userDidSwipe(sender: UISwipeGestureRecognizer) {
        self.delegate?.didSwipeImage(in: self, to: sender.direction)
        
    }


}
