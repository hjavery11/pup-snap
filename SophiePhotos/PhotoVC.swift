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
 
    
    let placeholderImage = UIImage(named: "placeholder_image")
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        setupSophiePhoto()
        setupHintText()
        setupCameraPreview()
        setupCameraView()
        createClearButton()
    }
    

    
    func setupSophiePhoto() {
        view.addSubview(referenceImageView)
        referenceImageView.translatesAutoresizingMaskIntoConstraints = false
        referenceImageView.isOpaque = true
  
        
        NSLayoutConstraint.activate([
            referenceImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            referenceImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 85),
            referenceImageView.widthAnchor.constraint(equalToConstant: 200),
            referenceImageView.heightAnchor.constraint(equalToConstant: 175)
            
        ])
    }
    
    func setupHintText() {
        view.addSubview(hintText)
        hintText.text = "*Image provided for reference"
        hintText.translatesAutoresizingMaskIntoConstraints = false
        hintText.font = UIFont.preferredFont(forTextStyle: .footnote)
        
        NSLayoutConstraint.activate([
            hintText.bottomAnchor.constraint(equalTo: referenceImageView.bottomAnchor),
            hintText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    func setupCameraPreview(){
        view.addSubview(cameraPreview)
        cameraPreview.translatesAutoresizingMaskIntoConstraints = false
        cameraPreview.image = placeholderImage
        let gesture = UITapGestureRecognizer(target: self, action: #selector(previewClicked))
        cameraPreview.isUserInteractionEnabled = true
     
        cameraPreview.addGestureRecognizer(gesture)
        
        
        NSLayoutConstraint.activate([
            cameraPreview.topAnchor.constraint(equalTo: referenceImageView.bottomAnchor, constant: 25),
            cameraPreview.widthAnchor.constraint(equalTo: view.widthAnchor),
            cameraPreview.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.75)
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
        clearButton.alpha = 1
      
        
        print(image.size)
    }

    func createClearButton() {
        view.addSubview(clearButton)
        clearButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        clearButton.tintColor = .systemRed
        clearButton.setTitle(" Clear Image", for: .normal)
        clearButton.setTitleColor(.systemRed, for: .normal)
        clearButton.translatesAutoresizingMaskIntoConstraints = false
        
        clearButton.addTarget(self, action: #selector(clearImage), for: .touchUpInside)
        clearButton.alpha = 0
        
        NSLayoutConstraint.activate([
            clearButton.topAnchor.constraint(equalTo: cameraPreview.bottomAnchor, constant: 20),
            clearButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    @objc func clearImage() {
        cameraPreview.image = placeholderImage
        clearButton.alpha = 0
    
    }
    
}

