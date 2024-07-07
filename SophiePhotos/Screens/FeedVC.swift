//
//  FeedVC.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/1/24.
//

import UIKit

class FeedVC: UIViewController, FullScreenPhotoVCDelegate {
    
    enum Section {
        case main
    }

    var photoArray: [Photo] = []
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Photo>?
    var currentImageIndex: Int?
    
    let spinnerChild = SpinnerVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        configureNavigationBar()
        createLoadingView()
        
        fetchPhotos()
        
        
    }
    
    func configureNavigationBar() {
        navigationController?.navigationBar.tintColor = .systemPurple
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
    func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createThreeColumnFlowLayout())
        view.addSubview(collectionView)
        collectionView.register(SophiePhotoCell.self, forCellWithReuseIdentifier: SophiePhotoCell.reuseID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func fetchPhotos() {
        Task{
            do {
                photoArray = try await NetworkManager.shared.fetchCompletePhotos()
                configureCollectionView()
                configureDataSource()
                applySnapshot()
                dismissLoadingView()
            } catch {
                print("Error: \(error)")
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
        
        let fullScreenVC = FullScreenPhotoVC(photo: photo, indexPath: nil)
        fullScreenVC.delegate = self
        if let navController = self.navigationController {
            navController.pushViewController(fullScreenVC, animated: true)
        } else {
            self.present(fullScreenVC, animated: true)
        }
        
    }
    
    func tabSelected() {
        checkForNewImages()
    }
    
    func checkForNewImages() {
//        Task {
//            let newPhotos = await NetworkManager.shared.getPhotos()
//            if newPhotos.count != photoArray.count {
//                photoArray = newPhotos
//                applySnapshot()
//            }
//        }
    }
    
    func deleteImage(at indexPath: IndexPath) {        
//        Task {
//            do {
//                try await NetworkManager.shared.deletePhoto(imageURL: urlArray[indexPath.item])
//                imageArray.remove(at: indexPath.item)
//                urlArray.remove(at: indexPath.item)
//               
//                applySnapshot()
//               
//            } catch {
//                let alert = UIAlertController(title: "Error", message: "Could not delete photo: \(error.localizedDescription)", preferredStyle: .alert)
//                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
//             
//                alert.addAction(alertAction)
//            
//                present(alert, animated: true, completion: nil)
//                print("Error occured deleting photo: \(error)")
//            }
//           
//        }
      
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
    
    func displayPriorImage(currentVC: FullScreenPhotoVC) {
//        guard let currentImageIndex = currentImageIndex else { return }
//        let priorIndex = currentImageIndex - 1
//        guard priorIndex >= 0, priorIndex < photoArray.count else { return }
//        
//        let priorPhoto = photoArray[priorIndex]
//
//        let newIndexPath = IndexPath(item: priorIndex, section: currentVC.indexPath?.section ?? 0) // future proof of more than 0 sections
//        
//        currentVC.photo = priorPhoto
//        currentVC.indexPath = newIndexPath
//        
//        self.currentImageIndex = priorIndex
//        
//        let currentImageView = currentVC.imageView
//        
//        // Create a new image view for the prior image
//        let newImageView = UIImageView(image: priorImage)
//        newImageView.contentMode = .scaleAspectFit
//        newImageView.frame = currentImageView.bounds
//        newImageView.frame.origin.x = -currentImageView.frame.width
//        
//        currentImageView.superview?.addSubview(newImageView)
//        currentImageView.image = nil
//        UIView.animate(withDuration: 0.2, animations: {
//            newImageView.frame.origin.x = 0
//            currentImageView.frame.origin.x = currentImageView.frame.width
//        }, completion: { _ in
//            currentImageView.frame.origin.x = 0
//            newImageView.removeFromSuperview()
//        })
//        currentImageView.image = priorImage
        
    }
    
    func displayNextImage(currentVC: FullScreenPhotoVC) {
//        guard let currentImageIndex = currentImageIndex else { return }
//        let nextIndex = currentImageIndex + 1
//        guard nextIndex >= 0, nextIndex < imageArray.count else { return }
//        
//        let nextImage = imageArray[nextIndex]
//        let nextURL = urlArray[nextIndex]
//        
//        currentVC.imageURL = nextURL
//        self.currentImageIndex = nextIndex
//        
//        let currentImageView = currentVC.imageView
//        
//        // Create a new image view for the next image
//        let newImageView = UIImageView(image: nextImage)
//        newImageView.contentMode = .scaleAspectFit
//        newImageView.frame = currentImageView.bounds
//        newImageView.frame.origin.x = currentImageView.frame.width
//        
//        currentImageView.superview?.addSubview(newImageView)
//        currentImageView.image = nil
//        UIView.animate(withDuration: 0.2, animations: {
//            newImageView.frame.origin.x = 0
//            currentImageView.frame.origin.x = -currentImageView.frame.width
//        }, completion: { _ in
//            currentImageView.frame.origin.x = 0
//            newImageView.removeFromSuperview()
//        })
//        currentImageView.image = nextImage
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


