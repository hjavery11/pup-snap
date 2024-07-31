//
//  FullScreenPhotoVC.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/2/24.
//

import UIKit

protocol FullScreenPhotoVCDelegate: AnyObject {
    func didSwipeImage(in viewController: FullScreenPhotoVC, to direction: UISwipeGestureRecognizer.Direction)
    func deleteImage(at indexPath: IndexPath)
    
    var ratingChange: Bool { get set }
}

class FullScreenPhotoVC: UIViewController, RatingViewControllerDelegate {

    weak var delegate: FullScreenPhotoVCDelegate?
    var activityIndicator = UIActivityIndicatorView(style: .large)
    var closeButton = UIButton()
    var captionView = UILabel()
    var totalRatingView = UILabel()
    var ratingView = RatingViewController()
    var imageView = UIImageView()
    
    private var didLayoutCaption: Bool = false
    private var imageLayoutDone: Bool = false
    
    var photo: Photo
    var indexPath: IndexPath?
    
    
    init(photo: Photo, indexPath: IndexPath, image: UIImage) {
        self.photo = photo
        self.indexPath = indexPath
        imageView.image = image      
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init (photo: Photo, imageView: UIImageView) {
        self.photo = photo
        self.imageView = imageView
        
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
            //dont show rating view if no indexPath
           
        }
        configureRatingView()
        setupLoading()
        addGestures()
    }
    
    override func viewSafeAreaInsetsDidChange() {
        layoutRatingView()
    }

    
    func configureImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        
        let aspectRatio = 0.75 //standard iphone vertical image
        let imageWidth = view.bounds.width
        let imageHeight = imageWidth / aspectRatio
        
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: imageWidth),
            imageView.heightAnchor.constraint(equalToConstant: imageHeight),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        print("view did configureImageView")
    }
    
    func configureCaptionView() {
        view.layoutIfNeeded()
        
        view.addSubview(captionView)
        captionView.translatesAutoresizingMaskIntoConstraints = false
        captionView.text = photo.caption
        captionView.font = UIFont(name: AppFonts.base.rawValue, size: 24)
        captionView.textColor = .label
        
        
        NSLayoutConstraint.activate([
            captionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            captionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            captionView.bottomAnchor.constraint(equalTo: imageView.topAnchor),
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
    
    func configureRatingView() {
        addChild(ratingView)
        view.addSubview(ratingView.view)
        ratingView.delegate = self
        ratingView.view.translatesAutoresizingMaskIntoConstraints = false
        ratingView.didMove(toParent: self)
        
        setUserRating()
        
    }
    
    func setUserRating() {
        let userID = PersistenceManager.retrieveID()
        if let userRating = photo.ratings[userID] {
            ratingView.rating = userRating
        } else {
            ratingView.rating = 0
        }
    }
    
    
    func layoutRatingView() {
        view.layoutIfNeeded()
        
        let heightAvail = view.safeAreaLayoutGuide.layoutFrame.maxY - imageView.frame.maxY
        
        NSLayoutConstraint.activate([
            ratingView.view.centerYAnchor.constraint(equalTo: imageView.bottomAnchor, constant: heightAvail / 2),
            ratingView.view.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75),
            ratingView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func updateRating(rating: Int) {
        photo.addRating(user: PersistenceManager.retrieveID(), rating: rating)
        setUserRating()
        
        delegate?.ratingChange = true
        
        Task {
            do {
                try await NetworkManager.shared.updatePhotoRating(photo: self.photo)
            } catch {
                print("Error updating photo rating: \(error.localizedDescription)")
            }
        }
        
        
        
    }
   

}
