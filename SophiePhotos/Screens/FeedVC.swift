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
    
    
    var imageArray: [UIImage] = []
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, UIImage>?
    var currentImageIndex: Int?
    
    let spinnerChild = SpinnerVC()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        createLoadingView()
        Task {
            await fetchPhotos()
            configureCollectionView()
            configureDataSource()
            applySnapshot()
            dismissLoadingView()
        }
        
        
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
    
    func fetchPhotos() async {
        imageArray = await NetworkManager.shared.getPhotos()
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
        dataSource = UICollectionViewDiffableDataSource<Section, UIImage>(collectionView: collectionView, cellProvider: { (collectionView, indexPath, image) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SophiePhotoCell.reuseID, for: indexPath) as? SophiePhotoCell else {
                fatalError("Cannot create new cell")
            }
            
            
            cell.set(image: image)
            cell.isUserInteractionEnabled = true
            let gesture = UITapGestureRecognizer(target: self, action: #selector(self.previewClicked))
            
            cell.addGestureRecognizer(gesture)
            
            return cell
        })
    }
    
    func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UIImage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(imageArray)
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    @objc func previewClicked(sender:UITapGestureRecognizer){
        guard let cell = sender.view as? SophiePhotoCell, let image = cell.thumbnailImageView.image else {
            print("error making cell")
            return
        }
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        currentImageIndex = indexPath.item
        
        let fullScreenVC = FullScreenPhotoVC(image: image)
        fullScreenVC.delegate = self
        self.present(fullScreenVC, animated: true)
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    func tabSelected() {
        checkForNewImages()
    }
    
    func checkForNewImages() {
        Task {
            let newImages = await NetworkManager.shared.getPhotos()
            if newImages.count != imageArray.count {
                imageArray = newImages
                applySnapshot()
            }
        }
    }
    
    func didDismissFullScreenPhotoVC() {
        print("full screen image dismissed")
    }
    
    func didSwipeImage(in viewController: FullScreenPhotoVC, to direction: UISwipeGestureRecognizer.Direction) {
        switch direction {
        case .left:
            displayPriorImage(currentVC: viewController)
        case .right:
            displayNextImage(currentVC: viewController)
        default:
            //do nothing
            break
        }
    }
    
    func displayPriorImage(currentVC: FullScreenPhotoVC) {
        guard let currentImageIndex = currentImageIndex else { return }
        let priorIndex = currentImageIndex - 1
        guard priorIndex >= 0, priorIndex < imageArray.count else { return }
        
        let priorImage = imageArray[priorIndex]
        self.currentImageIndex = priorIndex
        
        let currentImageView = currentVC.imageView
        
        // Create a new image view for the prior image
        let newImageView = UIImageView(image: priorImage)
        newImageView.contentMode = .scaleAspectFit
        newImageView.frame = currentImageView.bounds
        newImageView.frame.origin.x = currentImageView.frame.width
        
        currentImageView.superview?.addSubview(newImageView)
        
        UIView.animate(withDuration: 0.2, animations: {
            newImageView.frame.origin.x = 0
            currentImageView.frame.origin.x = -currentImageView.frame.width
        }, completion: { _ in
            currentImageView.image = priorImage
            currentImageView.frame.origin.x = 0
            newImageView.removeFromSuperview()
        })
    }

    
    func displayNextImage(currentVC: FullScreenPhotoVC) {
        guard let currentImageIndex = currentImageIndex else { return }
        let nextIndex = currentImageIndex + 1
        guard nextIndex >= 0, nextIndex < imageArray.count else { return }
        
        let nextImage = imageArray[nextIndex]
        self.currentImageIndex = nextIndex
        
        let currentImageView = currentVC.imageView
        
        // Create a new image view for the next image
        let newImageView = UIImageView(image: nextImage)
        newImageView.contentMode = .scaleAspectFit
        newImageView.frame = currentImageView.bounds
        newImageView.frame.origin.x = -currentImageView.frame.width
        
        currentImageView.superview?.addSubview(newImageView)
        
        UIView.animate(withDuration: 0.2, animations: {
            newImageView.frame.origin.x = 0
            currentImageView.frame.origin.x = currentImageView.frame.width
        }, completion: { _ in
            currentImageView.image = nextImage
            currentImageView.frame.origin.x = 0
            newImageView.removeFromSuperview()
        })
    }


    
}


//
//  UIEdgeInsets+Ext.swift
//  GHFollowers
//
//  Created by Harrison Javery on 7/2/24.
//

import UIKit

extension UIEdgeInsets {
    init(_ padding: CGFloat) {
        self.init(top: padding, left: padding, bottom: padding, right: padding)
    }
}
