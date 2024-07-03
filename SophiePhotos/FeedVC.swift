//
//  FeedVC.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/1/24.
//

import UIKit

class FeedVC: UIViewController {
    
    enum Section {
        case main
    }
    
    let imageArray: [UIImage] = [UIImage(named: "sophie-photo-1")!,UIImage(named:"sophie-photo-2")!,UIImage(named:"sophie-photo-3")!,UIImage(named:"sophie-photo-4")!]
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, UIImage>!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        configureCollectionView()
        configureDataSource()
        applySnapshot()
        
    }
    
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createThreeColumnFlowLayout())
        view.addSubview(collectionView)
        collectionView.register(SophiePhotoCell.self, forCellWithReuseIdentifier: SophiePhotoCell.reuseID)
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
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc func previewClicked(sender:UITapGestureRecognizer){
        guard let cell = sender.view as? SophiePhotoCell, let image = cell.thumbnailImageView.image else {
            print("error making cell")
            return
        }
        let imageView = UIImageView(image: image)
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        
        
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
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
