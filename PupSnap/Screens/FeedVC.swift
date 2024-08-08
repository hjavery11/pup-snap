//
//  FeedVC.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/1/24.
//

import UIKit
import SDWebImage

class FeedVC: UIViewController, FullScreenPhotoVCDelegate {
    
    enum Section {
        case main
    }
    
    enum Sort {
        case dateAsc, dateDesc, cuteDesc
    }

    var photoArray: [Photo] = []
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Photo>?
    var currentImageIndex: Int?
    let emptyView = UIView()
    
    var ratingChange: Bool = false
    
    let spinnerChild = SpinnerVC()
    
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    var currentSort: Sort = .dateDesc
    var dateSortAsc = UIAlertAction()
    var dateSortDesc = UIAlertAction()
    var cuteSortDesc = UIAlertAction()
    
    var filterView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setTitle()
        
        configureCollectionView()
        configureSort()
    
        createLoadingView()
        
        fetchPhotos()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        setTitle()
        if ratingChange {
            applySort()
            ratingChange = false
        }
     
    }
    
    func setTitle() {
        let name = LaunchManager.shared.dog?.name ?? "Dog"
        self.navigationItem.title = "\(name)'s Photos"
        
    }
    
    func createLoadingView() {
        // add spinner to view
        addChild(spinnerChild)
        spinnerChild.view.frame = view.frame
        view.addSubview(spinnerChild.view)
        spinnerChild.didMove(toParent: self)
    }
    
    func dismissLoadingView() {
        spinnerChild.willMove(toParent: nil)
        spinnerChild.view.removeFromSuperview()
        spinnerChild.removeFromParent()
    }
    
    func configureSort() {
        let sortButton = UIBarButtonItem(title: "Sort by", style: .plain, target: self, action: #selector(sortPhotos))
        sortButton.setTitleTextAttributes([
            NSAttributedString.Key.font: UIFont(name: AppFonts.base.rawValue, size: 18)!,
            NSAttributedString.Key.foregroundColor: AppColors.appPurple
        ], for: .normal)
        
        dateSortDesc = UIAlertAction(title: "Newest", style: .default) { _ in
            self.currentSort = .dateDesc
            self.applySort()
        }
        
        dateSortAsc = UIAlertAction(title: "Oldest", style: .default) { _ in
            self.currentSort = .dateAsc
            self.applySort()
        }
        
        dateSortDesc.isEnabled = false // disable on launch since default is by time
        
        cuteSortDesc = UIAlertAction(title: "Cutest", style: .default) { _ in
            self.currentSort = .cuteDesc
            self.applySort()
        }
       
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
       
        actionSheet.addAction(dateSortDesc)
        actionSheet.addAction(dateSortAsc)
        actionSheet.addAction(cuteSortDesc)
        actionSheet.addAction(cancel)
        
        navigationItem.rightBarButtonItem = sortButton
        
    }
    
    @objc func sortPhotos() {
        present(actionSheet, animated: true, completion: nil)
    }
    
    func applySort() {
        switch currentSort {
        case .dateDesc:
            photoArray.sort {
                $0.timestamp > $1.timestamp
            }
            dateSortDesc.isEnabled = false
            dateSortAsc.isEnabled = true
            cuteSortDesc.isEnabled = true
        case .cuteDesc:
            photoArray.sort {
                $0.userRating > $1.userRating
            }
            dateSortDesc.isEnabled = true
            dateSortAsc.isEnabled = true
            cuteSortDesc.isEnabled = false
        case .dateAsc:
            photoArray.sort {
                $0.timestamp < $1.timestamp
            }
            dateSortDesc.isEnabled = true
            dateSortAsc.isEnabled = false
            cuteSortDesc.isEnabled = true
        }
       
        self.applySnapshot()
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createThreeColumnFlowLayout())
        view.addSubview(collectionView)
        collectionView.register(SophiePhotoCell.self, forCellWithReuseIdentifier: SophiePhotoCell.reuseID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            
        ])
    }
    
    func fetchPhotos() {
        Task{
            do {
                photoArray = try await NetworkManager.shared.fetchCompletePhotos()
                configureDataSource()
                applySnapshot()
                dismissLoadingView()
            } catch {
                print("Error: \(error)")
            }
           
        }
    }
    
    func configureEmptyView() {
        emptyView.frame = CGRect(x: 0, y: 0, width: 330, height: 270)
        view.addSubview(emptyView)
        let shadows = UIView()
        shadows.frame = emptyView.frame
        shadows.clipsToBounds = false
        emptyView.addSubview(shadows)
        
        let shadowPath0 = UIBezierPath(roundedRect: shadows.bounds, cornerRadius: 14)
        let layer0 = CALayer()
        layer0.shadowPath = shadowPath0.cgPath
        layer0.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.03).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 30
        layer0.shadowOffset = CGSize(width: 10, height: 10)
        layer0.bounds = shadows.bounds
        layer0.position = shadows.center
        shadows.layer.addSublayer(layer0)
        let shapes = UIView()
        shapes.frame = emptyView.frame
        shapes.clipsToBounds = true
        emptyView.addSubview(shapes)
        let layer1 = CALayer()
        layer1.backgroundColor = UIColor(red: 0.22, green: 0.224, blue: 0.259, alpha: 1).cgColor
        layer1.bounds = shapes.bounds
        layer1.position = shapes.center
        shapes.layer.addSublayer(layer1)
        shapes.layer.cornerRadius = 14
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        
        let emptyImage = UIImageView(image: UIImage(named:"sophie-iso"))
        let titleText = UILabel()
        titleText.text = "No pictures yet..."
        let infoText = UILabel()
        infoText.text = "Add pictures of your pup to see them in the feed"
        let pictureButton = UIButton()
       
        emptyView.addSubview(emptyImage)
        emptyImage.translatesAutoresizingMaskIntoConstraints = false
        
        emptyView.addSubview(titleText)
        emptyView.addSubview(infoText)
        emptyView.addSubview(pictureButton)
        titleText.translatesAutoresizingMaskIntoConstraints = false
        infoText.translatesAutoresizingMaskIntoConstraints = false
        pictureButton.translatesAutoresizingMaskIntoConstraints = false
        
        titleText.font = UIFont(name: AppFonts.bold.rawValue, size: 16)
        titleText.textColor = .white
        infoText.font = UIFont(name: AppFonts.base.rawValue, size: 13)
        infoText.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.8)
        infoText.lineBreakMode = .byWordWrapping
        infoText.numberOfLines = 3
        infoText.textAlignment = .center
        
        pictureButton.backgroundColor = AppColors.appPurple
        pictureButton.titleLabel?.font = UIFont(name: AppFonts.semibold.rawValue, size: 16)
        pictureButton.titleLabel?.textColor = .white
        pictureButton.layer.cornerRadius = 8
        // create a NSMutableAttributedString with the text before the image
        let beginning = NSMutableAttributedString(string: "")
        let after = NSMutableAttributedString(string: "  Take Picture")

        // create a NSTextAttachment with the image
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "camera.fill")?.withTintColor(.white)

        // create an NSMutableAttributedString with the image
        let imageString = NSAttributedString(attachment: imageAttachment)

        // add the image to the string
        beginning.append(imageString)
        beginning.append(after)
        pictureButton.setAttributedTitle(beginning, for: .normal)
        pictureButton.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)

        
        NSLayoutConstraint.activate([
            emptyView.widthAnchor.constraint(equalToConstant: 330),
            emptyView.heightAnchor.constraint(equalToConstant: 270),
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            emptyImage.widthAnchor.constraint(equalToConstant: 82),
            emptyImage.heightAnchor.constraint(equalToConstant: 82),
            emptyImage.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 124),
            emptyImage.topAnchor.constraint(equalTo: emptyView.topAnchor, constant: 28),     
            
            titleText.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 114),
            titleText.topAnchor.constraint(equalTo: emptyImage.bottomAnchor, constant: 16),
            
            infoText.leadingAnchor.constraint(equalTo: emptyView.leadingAnchor, constant: 58),
            infoText.topAnchor.constraint(equalTo: titleText.bottomAnchor, constant: 8),
            infoText.widthAnchor.constraint(equalToConstant: 214),
            
            pictureButton.widthAnchor.constraint(equalToConstant: 150),
            pictureButton.heightAnchor.constraint(equalToConstant: 35),
            pictureButton.topAnchor.constraint(equalTo: infoText.bottomAnchor, constant: 16),
            pictureButton.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor)
            
        ])
    }
    
    @objc func addPhoto() {
          if let tabBarController = self.tabBarController {
              tabBarController.selectedIndex = 0 // Switch to the first tab (index starts from 0)
              if let photoVC = (tabBarController.viewControllers?[0] as? UINavigationController)?.topViewController as? PhotoVC {
                  photoVC.dogClicked(sender: UITapGestureRecognizer())
              }
          }
      }
    
    func createThreeColumnFlowLayout() -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding: CGFloat = 12
        let minimumItemSpacing: CGFloat = 10
        let availableWidth = width - (padding * 2) - (minimumItemSpacing * 2)
        let itemWidth = availableWidth / 3
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(padding)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
        
        return flowLayout
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Photo>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, photo) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SophiePhotoCell.reuseID, for: indexPath) as? SophiePhotoCell else {
                fatalError("Cannot create new cell")
            }
            
            cell.set(photo: photo)
            
            cell.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.previewClicked))
            
            cell.addGestureRecognizer(gesture)
            
            return cell
        })
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Photo>()
        snapshot.appendSections([.main])
        snapshot.appendItems(photoArray)
        dataSource?.apply(snapshot, animatingDifferences: true)
        if photoArray.isEmpty {
            configureEmptyView()            
        } else{
            emptyView.removeFromSuperview()
        }
    }
    
    @objc func previewClicked(sender: UITapGestureRecognizer) {
        guard let cell = sender.view as? SophiePhotoCell else {
            print("error making cell")
            return
        }
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        currentImageIndex = indexPath.item
        
        guard let photo = cell.photo else { return }
        guard let image = cell.thumbnailImageView.image else { return }
        let fullScreenVC = FullScreenPhotoVC(photo: photo, indexPath: indexPath, image: image)
        fullScreenVC.delegate = self
        if cell.thumbnailImageView.sd_currentDownloadTask == nil {
            if let navController = self.navigationController {
                navController.pushViewController(fullScreenVC, animated: true)
            } else {
                self.present(fullScreenVC, animated: true)
            }
        } else {
           
        }
    }
    
    func tabSelected() {
        checkForNewImages()
    }
    
    func checkForNewImages() {
        Task {
            do {
                let newPhotos = try await NetworkManager.shared.getPhotoCount()
                if newPhotos != photoArray.count {
                    photoArray = try await NetworkManager.shared.fetchCompletePhotos()
                    emptyView.removeFromSuperview()
                    applySnapshot()
                }
            } catch {
                print("error trying to check for new images, aborting refresh")
            }
        }
    }
    
    func deleteImage(at indexPath: IndexPath) {        
        Task {
            do {
                let deletedPhoto = photoArray[indexPath.item]
                try await NetworkManager.shared.deletePhoto(photo: deletedPhoto)
                photoArray.remove(at: indexPath.item)
               
                applySnapshot()
               
            } catch {
//                let alert = UIAlertController(title: "Error", message: "Could not delete photo: \(error.localizedDescription)", preferredStyle: .alert)
//                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
//             
//                alert.addAction(alertAction)
//            
//                present(alert, animated: true, completion: nil)
                print("Error occured deleting photo: \(error)")
                let deletedPhoto = photoArray[indexPath.item]
        
                try await NetworkManager.shared.deletePhoto(photo: deletedPhoto)
                photoArray.remove(at: indexPath.item)
               
                applySnapshot()
             
            }
           
        }
      
    }
    
    func didSwipeImage(in viewController: FullScreenPhotoVC, to direction: UISwipeGestureRecognizer.Direction) {
        switch direction {
        case .left:
            displayNextImage(currentVC: viewController)
        case .right:
            displayPriorImage(currentVC: viewController)
        default:
            // do nothing
            break
        }
    }
    
    func getCellForItem(at indexPath: IndexPath) -> SophiePhotoCell? {
        return collectionView.cellForItem(at: indexPath) as? SophiePhotoCell
    }
    
    func displayPriorImage(currentVC: FullScreenPhotoVC) {
        guard let currentImageIndex = currentImageIndex else { return }
        let priorIndex = currentImageIndex - 1
        guard priorIndex >= 0, priorIndex < photoArray.count else { return }
        
        let priorPhoto = photoArray[priorIndex]

        let newIndexPath = IndexPath(item: priorIndex, section: currentVC.indexPath?.section ?? 0) // future proof of more than 0 sections
        
        currentVC.photo = priorPhoto
        currentVC.indexPath = newIndexPath
        
        self.currentImageIndex = priorIndex
        
        // Retrieve the cell and get the image from its thumbnailImageView
           guard let priorCell = getCellForItem(at: newIndexPath),
                 let priorImage = priorCell.thumbnailImageView.image else { return }
        
        let currentImageView = currentVC.imageView
        
        //change captions
        currentVC.captionView.text = priorPhoto.caption
        //change rating
        currentVC.setUserRating()
        
        // Create a new image view for the prior image
        let newImageView = UIImageView(image: priorImage)
        newImageView.frame = currentImageView.frame
        newImageView.frame.origin.x = -currentImageView.frame.width
        
        currentImageView.superview?.addSubview(newImageView)
        currentImageView.image = nil
        UIView.animate(withDuration: 0.2, animations: {
            newImageView.frame.origin.x = 0
            currentImageView.frame.origin.x = currentImageView.frame.width
        }, completion: { _ in
            currentImageView.frame.origin.x = 0
            newImageView.removeFromSuperview()
        })
        currentImageView.image = priorImage
        
    }
    
    func displayNextImage(currentVC: FullScreenPhotoVC) {
        guard let currentImageIndex = currentImageIndex else { return }
        let nextIndex = currentImageIndex + 1
        guard nextIndex >= 0, nextIndex < photoArray.count else { return }
        
        let nextPhoto = photoArray[nextIndex]
        let newIndexPath = IndexPath(item: nextIndex, section: currentVC.indexPath?.section ?? 0) // future proof of more than 0 sections
        
        self.currentImageIndex = nextIndex
        
        currentVC.photo = nextPhoto
        currentVC.indexPath = newIndexPath
        
        // Retrieve the cell and get the image from its thumbnailImageView
            guard let nextCell = getCellForItem(at: newIndexPath),
                  let nextImage = nextCell.thumbnailImageView.image else { return }
        
        let currentImageView = currentVC.imageView
        
        //change captions
        currentVC.captionView.text = nextPhoto.caption
        //change rating
        currentVC.setUserRating()
        
        // Create a new image view for the next image
        let newImageView = UIImageView(image: nextImage)
        newImageView.frame = currentImageView.frame
        newImageView.frame.origin.x = currentImageView.frame.width
        
        currentImageView.superview?.addSubview(newImageView)
        currentImageView.image = nil
        UIView.animate(withDuration: 0.2, animations: {
            newImageView.frame.origin.x = 0
            currentImageView.frame.origin.x = -currentImageView.frame.width
        }, completion: { _ in
            currentImageView.frame.origin.x = 0
            newImageView.removeFromSuperview()
        })
        currentImageView.image = nextImage
    }
    
}
//
//  UIEdgeInsets+Ext.swift
//  GHFollowers
//
//  Created by Harrison Javery on 7/2/24.
//

extension UIEdgeInsets {
    init(_ padding: CGFloat) {
        self.init(top: padding, left: padding, bottom: padding, right: padding)
    }
}


