//
//  FullScreenPhotoVC.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/2/24.
//

import UIKit

protocol FullScreenPhotoVCDelegate: AnyObject {
    func didSwipeImage(in viewController: FullScreenPhotoVC, to direction: UISwipeGestureRecognizer.Direction)
    func deleteImage(at indexPath: IndexPath)
}

class FullScreenPhotoVC: UIViewController {

    weak var delegate: FullScreenPhotoVCDelegate?
    var activityIndicator = UIActivityIndicatorView(style: .large)
    var closeButton = UIButton()
    var imageView = UIImageView()
    var captionView = UILabel()
    
    var photo: Photo
    var indexPath: IndexPath?
    
    init(photo: Photo, indexPath: IndexPath?) {
        self.photo = photo
        self.indexPath = indexPath
        
        super.init(nibName: nil, bundle: nil)
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
      
        configureImageView()
        configureCaptionView()
        if self.indexPath != nil {
            // only show nav bar if coming from feed view, otherwise its a push notification without nav bar
            configureNavBar()
        }      
        setupLoading()
        addGestures()
        
        if self.photo.image == nil {
            print("No image set from push notification. Grabbing image")
            activityIndicator.startAnimating() // Show loading indicator
            
            // Safely unwrap the path
            guard let path = self.photo.path else {
                print("Invalid path")
                activityIndicator.stopAnimating()
                return
            }
            
            Task {
                do {
                    if let image = try await FirebaseHelper().fetchImage(url: path) {
                        DispatchQueue.main.async {
                            self.photo.setImage(to: image)
                            self.imageView.image = image
                            self.activityIndicator.stopAnimating() // Hide loading indicator
                        }
                    } else {
                        print("Error creating image from data")
                        DispatchQueue.main.async {
                            self.activityIndicator.stopAnimating() // Hide loading indicator
                        }
                    }
                } catch {
                    print("Error trying to fetch image for push notification: \(error)")
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating() // Hide loading indicator
                    }
                }
            }
        }
        
    }
    
    func configureImageView() {
        imageView.image = photo.image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        
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
        captionView.text = photo.caption
        captionView.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .headline), size: 24)
        captionView.textColor = .label
        captionView.textAlignment = .center
        captionView.numberOfLines = 3
        
        NSLayoutConstraint.activate([
            captionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            captionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            captionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            captionView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    func configureNavBar() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(userTappedDelete))
        navigationItem.rightBarButtonItem = deleteButton
    }
    func addGestures() {
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.userDidSwipe))
        leftGesture.direction = [.left]
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.userDidSwipe))
        rightGesture.direction = [.right]
        self.view.addGestureRecognizer(leftGesture)
        self.view.addGestureRecognizer(rightGesture)
    }

    func setupLoading() {
        // configure loading spinner
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc func userDidSwipe(sender: UISwipeGestureRecognizer) {
        self.delegate?.didSwipeImage(in: self, to: sender.direction)
        
    }
    
    @objc func userTappedDelete() {
        let alert = UIAlertController(title: "Delete Photo", message: "Are you sure you want to permanantely delete this photo?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.deleteCurrentPhoto()
        }
        let noAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alert.dismiss(animated: true)
        }
        alert.addAction(yesAction)
        alert.addAction(noAction)
        self.present(alert, animated: true)
    }
    
    func deleteCurrentPhoto() {
        if let indexPath = indexPath {
            self.navigationController?.popViewController(animated: true)
            self.delegate?.deleteImage(at: indexPath)
        } else {
            print("no index path set to delete current photo")
        }
        
    }

}
