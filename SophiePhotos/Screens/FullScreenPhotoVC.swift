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
    
    var imageURL: String
    var indexPath: IndexPath?
    
    
    
    init(imageURL: String, image: UIImage? = nil, indexPath: IndexPath? = nil){
        self.imageURL = imageURL
        self.indexPath = indexPath
        super.init(nibName: nil, bundle: nil)
       
        //check which init
        if let image = image {
            self.imageView.image = image
        } else {
            fetchImage(url:imageURL)
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        configureImageView()
        if let _ = self.indexPath {
            configureNavBar()
        }      
        setupLoading()
        addGestures()
        
       
    }
    
    func configureImageView() {
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
    
    func configureNavBar() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(userTappedDelete))
        navigationItem.rightBarButtonItem = deleteButton
    }
    func addGestures() {
        let leftGesture = UISwipeGestureRecognizer(target: self , action: #selector(self.userDidSwipe))
        leftGesture.direction = [.left]
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.userDidSwipe))
        rightGesture.direction = [.right]
        self.view.addGestureRecognizer(leftGesture)
        self.view.addGestureRecognizer(rightGesture)
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
    
    
    @objc func userDidSwipe(sender: UISwipeGestureRecognizer) {
        self.delegate?.didSwipeImage(in: self, to: sender.direction)
        
    }
    
    @objc func userTappedDelete() {
        let alert = UIAlertController(title: "Delete Photo", message: "Are you sure you want to permanantely delete this photo?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.deleteCurrentPhoto()
        }
        let noAction = UIAlertAction(title: "Cancel", style: .cancel){ _ in
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
