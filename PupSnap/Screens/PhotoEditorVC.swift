//
//  PhotoEditorVC.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/4/24.
//

import UIKit

protocol PhotoEditorVCDelegate: AnyObject {
    func photoEditorDidRequestBack(_ editor: PhotoEditorVC)
    func photoEditorDidUpload(_ editor: PhotoEditorVC)
}

class PhotoEditorVC: UIViewController, UITextFieldDelegate {
    
    var delegate: PhotoEditorVCDelegate?
    var image: UIImage
    let imageView = UIImageView()
    let bottomBar = UIView()
    let topBar = UIView()
    let cuteScale = RatingViewController()
    
    let captionField = UITextField()
    
    let retakeButton = UIButton()
    let submitButton = UIButton()
    let closeButton = UIButton(type: .system)
    // Create a UIImage.SymbolConfiguration with the desired point size
    let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
    let buttonPadding: CGFloat = 18
    let topNavPadding: CGFloat = 15
    
    let pageFont = "Avenir"
    
    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBottomBarWhenPushed = true
        view.backgroundColor = .systemGray6
        
        setupBottomActionBar()
        setupTopActionBar()
        setupBottomActionItems()
        setupTopActionItems()
        setupImageView()
        setupTitle()
        setupCaptionField()
        setupRatingsViewController()
        setupCuteScale()
        //draw borderes
        setupDividers()
        
        calculateImageViewHeight()
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func calculateImageViewHeight() {
        let captionHeight = captionField.frame.height
        let ratingHeight = cuteScale.view.frame.height
        let bottomBarHeight = bottomBar.frame.height
        let topBarHeight = topBar.frame.height
        let currentImageHeight = imageView.frame.height
        
        print("current screen height is: \(view.frame.height) with image height: \(currentImageHeight), captionHeight: \(captionHeight), rating height: \(ratingHeight), top bar height: \(topBarHeight), botto mbar height: \(bottomBarHeight)")
        
        
    }
    
    func setupImageView() {
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        
        // Add border to the imageView
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.secondaryLabel.cgColor
        
        view.addSubview(imageView)
        
        let maxHeight: CGFloat = 350
        let padding: CGFloat = 80
        let aspectRatio = image.size.width / image.size.height
        let imageWidth = view.bounds.width - (padding * 2)
        var imageHeight = imageWidth / aspectRatio
        
        print("pre-update: image width: \(imageWidth) by height: \(imageHeight)")
        
        if imageHeight > maxHeight {
            imageHeight = maxHeight
        }
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 30),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            imageView.heightAnchor.constraint(equalToConstant: imageHeight)
        ])
    }

    func setupBottomActionBar() {
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(bottomBar)
        
        NSLayoutConstraint.activate([
            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 45),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    func setupTopActionBar() {
        topBar.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(topBar)
        
        NSLayoutConstraint.activate([
            topBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBar.widthAnchor.constraint(equalTo: view.widthAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 50),
            topBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
    }
    
    func setupDividers() {
        let dividerTop = UIView()
        dividerTop.backgroundColor = .systemGray4
        dividerTop.translatesAutoresizingMaskIntoConstraints = false
        dividerTop.layer.opacity = 0.75
        
        view.addSubview(dividerTop)
        
        let dividerRating = UIView()
        dividerRating.backgroundColor = .systemGray2
        dividerRating.translatesAutoresizingMaskIntoConstraints = false
        dividerRating.layer.opacity = 0.75
        
        view.addSubview(dividerRating)
        
        NSLayoutConstraint.activate([
            dividerTop.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 10),
            dividerTop.widthAnchor.constraint(equalTo: topBar.widthAnchor),
            dividerTop.heightAnchor.constraint(equalToConstant: 0.35),
            dividerTop.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            
            dividerRating.topAnchor.constraint(equalTo: captionField.bottomAnchor, constant: 20),
            dividerRating.widthAnchor.constraint(equalTo: view.widthAnchor),
            dividerRating.heightAnchor.constraint(equalToConstant: 0.35),
            dividerRating.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
    }
    
    func setupTitle() {
        let titleText = "Add Photo"
        let title = UILabel()
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont(name: AppFonts.bold.rawValue, size: 18)
        //title.font = UIFont.boldSystemFont(ofSize: 18)
        title.text = titleText
        title.textAlignment = .center
        title.textColor = .label
        
        view.addSubview(title)
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: topBar.leadingAnchor),
            title.trailingAnchor.constraint(equalTo: topBar.trailingAnchor),
            title.topAnchor.constraint(equalTo: topBar.topAnchor, constant: topNavPadding),
            title.bottomAnchor.constraint(equalTo: topBar.bottomAnchor)
        ])
        
    }
    
    func setupBottomActionItems() {
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.setTitle("Upload ", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.layer.cornerRadius = 25
        submitButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        submitButton.tintColor = .white
        
        submitButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        submitButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        submitButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        submitButton.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
        
        retakeButton.translatesAutoresizingMaskIntoConstraints = false
        retakeButton.setTitle("Back", for: .normal)
        retakeButton.backgroundColor = .systemGray
        retakeButton.layer.cornerRadius = 25
        retakeButton.tintColor = .white
        
        retakeButton.addTarget(self, action: #selector(showCamera), for: .touchUpInside)
        
        
        view.addSubview(submitButton)
        view.addSubview(retakeButton)
        
        
        
        NSLayoutConstraint.activate([
            submitButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -buttonPadding),
            submitButton.widthAnchor.constraint(equalToConstant: 110),
            submitButton.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),
            submitButton.heightAnchor.constraint(equalTo: bottomBar.heightAnchor),
            
            retakeButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: buttonPadding),
            retakeButton.widthAnchor.constraint(equalToConstant: 90),
            retakeButton.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),
            retakeButton.heightAnchor.constraint(equalTo: bottomBar.heightAnchor)
        ])
    }
    
    @objc func dismissEditor() {
        dismiss(animated: true)
    }
    
    @objc func addPhoto() {
        dismiss(animated: true)
        delegate?.photoEditorDidUpload(self)
    }
    
    @objc func showCamera() {
        delegate?.photoEditorDidRequestBack(self)
    }
    
    func setupTopActionItems() {
        let closeImage = UIImage(systemName: "xmark", withConfiguration: configuration)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = .label
        
        closeButton.addTarget(self, action: #selector(dismissEditor), for: .touchUpInside)
        
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: topBar.leadingAnchor, constant: buttonPadding),
            closeButton.topAnchor.constraint(equalTo: topBar.topAnchor, constant: topNavPadding),
            closeButton.bottomAnchor.constraint(equalTo: topBar.bottomAnchor),
        ])
    }
    
    func setupCaptionField() {
        view.addSubview(captionField)
        
        captionField.placeholder = "Write a caption..."
        captionField.keyboardType = .default
        captionField.textColor = .label
        captionField.translatesAutoresizingMaskIntoConstraints = false
        
        captionField.clearButtonMode = .whileEditing
        captionField.returnKeyType = .done
        captionField.delegate = self
        captionField.font = UIFont(name: pageFont, size: 20)
        
        NSLayoutConstraint.activate([
            captionField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 35),
            captionField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            captionField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20),
        ])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setupRatingsViewController() {
        addChild(cuteScale)
        cuteScale.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cuteScale.view)
        cuteScale.didMove(toParent: self)
    }
    
    func setupCuteScale() {
        view.layoutIfNeeded()
        
        let yConst = (bottomBar.frame.minY - imageView.frame.maxY) / 2 // calculate how to put rating scale in middle of caption and bottom bar
        
        NSLayoutConstraint.activate([
            cuteScale.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cuteScale.view.centerYAnchor.constraint(equalTo: imageView.bottomAnchor, constant: yConst),
            cuteScale.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            cuteScale.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
        ])
        
        cuteScale.didMove(toParent: self)
        
        drawLabels()
    }
    
    func drawLabels() {
        let labels = ["Derp", "Average", "Cutest"]
        let positions = [0, 2, 4] // 1st, 3rd, and 5th star buttons
        var labelViews: [UILabel] = []
        var lineViews: [UIView] = []
        
        for (index, position) in positions.enumerated() {
            guard position < cuteScale.starButtons.count else { continue }
            let starButton = cuteScale.starButtons[position]
            
            // Label
            let label = UILabel()
            label.text = labels[index]
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            label.font = UIFont(name: pageFont, size: 20)
            label.textColor = .label
            label.layer.opacity = 0.7
            labelViews.append(label)
            
            // Line
            let line = UIView()
            line.backgroundColor = .systemGray
            line.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(line)
            line.layer.opacity = 0.5
            lineViews.append(line)
            
            NSLayoutConstraint.activate([
                // Label Constraints
                label.bottomAnchor.constraint(equalTo: starButton.topAnchor, constant: -40),
                label.centerXAnchor.constraint(equalTo: starButton.centerXAnchor),
                
                // Line Constraints
                line.bottomAnchor.constraint(equalTo: starButton.topAnchor, constant: 10),
                line.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 5),
                line.widthAnchor.constraint(equalToConstant: 1),
                line.centerXAnchor.constraint(equalTo: starButton.centerXAnchor),
            ])
        }
    }
    
    
}

