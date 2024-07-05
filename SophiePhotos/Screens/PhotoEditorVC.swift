//
//  PhotoEditorVC.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/4/24.
//

import UIKit

class PhotoEditorVC: UIViewController, UITextFieldDelegate {
    
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
        setupDivider()
        setupBottomActionItems()
        setupTopActionItems()
        setupImageView()
        setupTitle()
        setupCaptionField()
        setupCuteScale()
        
        // Add tap gesture recognizer to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupImageView() {
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        
        view.addSubview(imageView)
        
        let padding: CGFloat = 80
        
        let aspectRatio = image.size.width / image.size.height
        
        let imageWidth = view.bounds.width - (padding * 2)
        let imageHeight = imageWidth / aspectRatio
        
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
    
    func setupDivider() {
        let divider = UIView()
        divider.backgroundColor = .systemGray4
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.layer.opacity = 0.75
        
        view.addSubview(divider)
        
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: topBar.bottomAnchor, constant: 10),
            divider.widthAnchor.constraint(equalTo: topBar.widthAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),
            divider.leadingAnchor.constraint(equalTo: topBar.leadingAnchor)
        ])
        
    }
    
    func setupTitle() {
        let titleText = "Add Photo"
        let title = UILabel()
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.boldSystemFont(ofSize: 18)
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
        submitButton.setTitle("Next ", for: .normal)
        submitButton.backgroundColor = .systemBlue
        submitButton.layer.cornerRadius = 25
        submitButton.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        submitButton.tintColor = .white
        
        submitButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        submitButton.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        submitButton.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        
        retakeButton.translatesAutoresizingMaskIntoConstraints = false
        retakeButton.setTitle("Retake", for: .normal)
        retakeButton.backgroundColor = .systemGray
        retakeButton.layer.cornerRadius = 25
        retakeButton.tintColor = .white
        
        
        view.addSubview(submitButton)
        view.addSubview(retakeButton)
        
        
        
        NSLayoutConstraint.activate([
            submitButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -buttonPadding),
            submitButton.widthAnchor.constraint(equalToConstant: 90),
            submitButton.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),
            submitButton.heightAnchor.constraint(equalTo: bottomBar.heightAnchor),
            
            retakeButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: buttonPadding),
            retakeButton.widthAnchor.constraint(equalToConstant: 90),
            retakeButton.bottomAnchor.constraint(equalTo: bottomBar.bottomAnchor),
            retakeButton.heightAnchor.constraint(equalTo: bottomBar.heightAnchor)
        ])
    }
    
    func setupTopActionItems() {
        let closeImage = UIImage(systemName: "xmark", withConfiguration: configuration)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(closeImage, for: .normal)
        closeButton.tintColor = .label
        
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
        captionField.font = UIFont(name: "Avenir", size: 18)
        
        NSLayoutConstraint.activate([
            captionField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -5),
            captionField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            captionField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20),
            captionField.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func setupCuteScale() {
        addChild(cuteScale)
        cuteScale.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cuteScale.view)
        
        NSLayoutConstraint.activate([
            cuteScale.view.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cuteScale.view.bottomAnchor.constraint(equalTo: bottomBar.topAnchor, constant: -20),
            cuteScale.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cuteScale.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            cuteScale.view.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        cuteScale.didMove(toParent: self)
        
        
    }
}

