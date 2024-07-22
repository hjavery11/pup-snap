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
    
    var photo: Photo
    var indexPath: IndexPath?
    
    
    init(photo: Photo, indexPath: IndexPath?, image: UIImage) {
        self.photo = photo
        self.indexPath = indexPath
        imageView.image = image      
        
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
            configureRatingView()
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
    
    func configureCaptionView() {
        view.addSubview(captionView)
        captionView.translatesAutoresizingMaskIntoConstraints = false
        captionView.text = photo.caption
        captionView.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .headline), size: 24)
        captionView.textColor = .label
        
        
        NSLayoutConstraint.activate([
            captionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            captionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
        ])
    }
    
    func configureTotalRatingView() {
        view.addSubview(totalRatingView)
        totalRatingView.text = "Cute Rating: \(photo.averageRating)/5"
        totalRatingView.translatesAutoresizingMaskIntoConstraints = false
        
        let width = (view.frame.width - 20) / 2
        
        NSLayoutConstraint.activate([
            totalRatingView.topAnchor.constraint(equalTo: captionView.topAnchor),
            totalRatingView.leadingAnchor.constraint(equalTo: captionView.trailingAnchor, constant: 10),
            totalRatingView.widthAnchor.constraint(equalToConstant: width)
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
        layoutRatingView()
        
    }
    
    func setUserRating() {
        let userID = PersistenceManager.retrieveID()
        if let userRating = photo.ratings[userID], userRating > 0{
            ratingView.rating = userRating
            print("user rating is \(userRating)")
            for button in ratingView.starButtons {
                button.isUserInteractionEnabled = false
            }
        } else {
            ratingView.rating = 0
            for button in ratingView.starButtons {
                button.isUserInteractionEnabled = true
            }
        }
        
        delegate?.ratingChange = true
       
    }
    
    
    func layoutRatingView() {
        view.layoutIfNeeded()
        
        NSLayoutConstraint.activate([
            ratingView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ratingView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ratingView.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            ratingView.view.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }
    
    func updateRating(rating: Int) {
        photo.addRating(user: PersistenceManager.retrieveID(), rating: rating)
        setUserRating()
        
        Task {
            do {
                try await NetworkManager.shared.updatePhotoRating(photo: self.photo)
                ratingView.view.removeFromSuperview()
                view.addSubview(ratingView.view)
                layoutRatingView()
                
            } catch {
                print("Error updating photo rating: \(error.localizedDescription)")
            }
        }
        
    }
   

}
