//
//  FeedVC.swift
//  PupSnap
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
    let emptyView = UITextView()
    
    let spinnerChild = SpinnerVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        setTitle()
        
        configureNavigationBar()
        createLoadingView()
        
        fetchPhotos()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setTitle()
    }
    
    func setTitle() {
        let name = PersistenceManager.getDogName() ?? "Dog"
        self.navigationItem.title = "🐶 \(name) Photos"
        
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
    
    func configureEmptyView() {
        emptyView.text = "No Photos 🐶"
        view.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        emptyView.textAlignment = .center
        emptyView.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            emptyView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyView.widthAnchor.constraint(equalTo: view.widthAnchor),
            emptyView.heightAnchor.constraint(equalToConstant: 100)
        ])
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
        
        let fullScreenVC = FullScreenPhotoVC(photo: photo, indexPath: indexPath)
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
                let alert = UIAlertController(title: "Error", message: "Could not delete photo: \(error.localizedDescription)", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
             
                alert.addAction(alertAction)
            
                present(alert, animated: true, completion: nil)
                print("Error occured deleting photo: \(error)")
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
    
    func displayPriorImage(currentVC: FullScreenPhotoVC) {
        guard let currentImageIndex = currentImageIndex else { return }
        let priorIndex = currentImageIndex - 1
        guard priorIndex >= 0, priorIndex < photoArray.count else { return }
        
        let priorPhoto = photoArray[priorIndex]

        let newIndexPath = IndexPath(item: priorIndex, section: currentVC.indexPath?.section ?? 0) // future proof of more than 0 sections
        
        currentVC.photo = priorPhoto
        currentVC.indexPath = newIndexPath
        
        self.currentImageIndex = priorIndex
        
        let currentImageView = currentVC.imageView
        
        //change captions
        currentVC.captionView.text = priorPhoto.caption
        //change rating
        currentVC.setUserRating()
        
        // Create a new image view for the prior image
        let newImageView = UIImageView(image: priorPhoto.image)
        newImageView.contentMode = .scaleAspectFit
        newImageView.frame = currentImageView.bounds
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
        currentImageView.image = priorPhoto.image
        
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
        
        let currentImageView = currentVC.imageView
        
        //change captions
        currentVC.captionView.text = nextPhoto.caption
        //change rating
        currentVC.setUserRating()
        
        // Create a new image view for the next image
        let newImageView = UIImageView(image: nextPhoto.image)
        newImageView.contentMode = .scaleAspectFit
        newImageView.frame = currentImageView.bounds
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
        currentImageView.image = nextPhoto.image
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


