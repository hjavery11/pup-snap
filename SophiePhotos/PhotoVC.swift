//
//  ViewController.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/1/24.
//

import UIKit

class PhotoVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    

    let hintText = UILabel()
    let referenceImageView = UIImageView(image: UIImage(named: "sophie"))
    let cameraPreview = UIImageView()
    let cameraVC = UIImagePickerController()
    let clearButton = UIButton()
    let submitButton = UIButton()
    
    var placeholderImage = UIImage()

    
    init() {
        super.init(nibName: nil, bundle: nil)
        placeholderImage = UIImage(systemName: "photo")!
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        setupCameraPreview()
        setupCameraView()
        setupSophiePhoto()
        setupHintText()
        createSubmitButton()
        createClearButton()
    }
    

    
    func setupSophiePhoto() {
        view.addSubview(referenceImageView)
        referenceImageView.translatesAutoresizingMaskIntoConstraints = false
        referenceImageView.isOpaque = true

  
        
        NSLayoutConstraint.activate([
            referenceImageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            referenceImageView.widthAnchor.constraint(equalToConstant: 548 / 5), // using base dimensions to ensure it stays in aspect ratio
            referenceImageView.heightAnchor.constraint(equalToConstant: 900 / 5),
            referenceImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50)
            
        ])
    }
    
    func setupHintText() {
        view.addSubview(hintText)
        hintText.text = "*Image provided for reference"
        hintText.translatesAutoresizingMaskIntoConstraints = false
        hintText.font = UIFont.preferredFont(forTextStyle: .footnote)
        
        NSLayoutConstraint.activate([
            hintText.bottomAnchor.constraint(equalTo: referenceImageView.bottomAnchor),
            hintText.leadingAnchor.constraint(equalTo: referenceImageView.trailingAnchor, constant: 5)
        ])
    }
    
    func setupCameraPreview(){
        view.addSubview(cameraPreview)
        cameraPreview.translatesAutoresizingMaskIntoConstraints = false
        cameraPreview.image = placeholderImage
        cameraPreview.tintColor = .label
        cameraPreview.layer.cornerRadius = 10
        let gesture = UITapGestureRecognizer(target: self, action: #selector(previewClicked))
        cameraPreview.isUserInteractionEnabled = true
        cameraPreview.addGestureRecognizer(gesture)

        
        NSLayoutConstraint.activate([
            cameraPreview.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -60),
            cameraPreview.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraPreview.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            cameraPreview.heightAnchor.constraint(equalTo: cameraPreview.widthAnchor, multiplier: 3.0/4.0)
        ])
    }
    
    @objc func previewClicked(sender:UITapGestureRecognizer){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            present(cameraVC, animated: true)
        } else {
            let alert = UIAlertController(title: "No Camera Access", message: "Please allow access to the camera in settings in order to take a photo.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
       
    }
    
    func setupCameraView() {
        cameraVC.sourceType = .camera
        cameraVC.allowsEditing = true
        cameraVC.delegate = self
        cameraVC.cameraFlashMode = .off
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
      
        
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        

        cameraPreview.image = image
        cameraPreview.layer.cornerRadius = 10
     
        clearButton.alpha = 1
        submitButton.alpha = 1
        view.updateConstraints()
      
        
       
    }

    func createClearButton() {
        view.addSubview(clearButton)
        clearButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        clearButton.tintColor = .white
        clearButton.setTitle(" Clear Image", for: .normal)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        clearButton.backgroundColor = .systemRed
        clearButton.layer.cornerRadius = 10
        
        
        clearButton.addTarget(self, action: #selector(clearImage), for: .touchUpInside)
        clearButton.alpha = 0
        
        
        NSLayoutConstraint.activate([
            clearButton.topAnchor.constraint(equalTo: cameraPreview.bottomAnchor, constant: 12),
            clearButton.leadingAnchor.constraint(equalTo: cameraPreview.leadingAnchor),
            clearButton.heightAnchor.constraint(equalTo: submitButton.heightAnchor),
            clearButton.widthAnchor.constraint(equalToConstant: 125)
        ])
    }
    
    func createSubmitButton() {
        view.addSubview(submitButton)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.tintColor = .white
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.backgroundColor = .systemBlue
        submitButton.layer.cornerRadius = 10
        submitButton.alpha = 0
        submitButton.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: cameraPreview.bottomAnchor, constant: 12),
            submitButton.trailingAnchor.constraint(equalTo: cameraPreview.trailingAnchor),
            submitButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    @objc func addPhoto() {
        print("photo added")
    }
    @objc func clearImage() {
        cameraPreview.image = placeholderImage
        clearButton.alpha = 0
        submitButton.alpha = 0
    
    }
    
}

