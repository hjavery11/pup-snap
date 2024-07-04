//
//  PhotoVC.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/1/24.
//
import UIKit
import FirebaseStorage

class PhotoVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    let hintText = UILabel()
    let referenceImageView = UIImageView(image: UIImage(named: "sophie"))
    let cameraPreview = UIImageView()
    let cameraVC = UIImagePickerController()
    let clearButton = UIButton()
    let submitButton = UIButton()
    let spinnerChild = SpinnerVC()
    
    
    let imageWidth: CGFloat = 85 * 3 // easily keep the 3:4 ratio using a base value
    let imageHeight: CGFloat = 85 * 4
    
    let buttonFont: CGFloat = 16
    let largeConfig = UIImage.SymbolConfiguration(pointSize: 44, weight: .bold, scale: .default)
    
    var fontType: UIFont?
    
    var placeholderImage = UIImage(systemName: "photo")
    
    // Reference to the height constraint of referenceImageView
    var referenceImageViewHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let deviceWidth = UIScreen.main.bounds.width
        let largeTitleFontSize: CGFloat
        
        
        //set font szie based off width of screen
        if deviceWidth > 375 {
            largeTitleFontSize = 34
            fontType = UIFont.systemFont(ofSize: 12)
        } else {
            largeTitleFontSize = 28
            fontType = UIFont.systemFont(ofSize: 10)
        }
        
        
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: largeTitleFontSize, weight: .bold)
        ]
        
        setupCameraPreview()
        setupCameraView()
        setupSophiePhoto()
        setupHintText()
        createSubmitButton()
        createClearButton()
        setupConstraints()
    }
   
    func setupConstraints() {
        setupCameraPreviewConstraints()
        setupClearButtonConstraints()
        setupSubmitButtonConstraints()
        setupReferenceImageViewConstraints()
        setupHintTextConstraints()
    }
    
    func setupCameraPreviewConstraints() {
        NSLayoutConstraint.activate([
            cameraPreview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cameraPreview.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cameraPreview.widthAnchor.constraint(equalToConstant: imageWidth),
            cameraPreview.heightAnchor.constraint(equalToConstant: imageHeight)
        ])
    }
    
    func setupClearButtonConstraints() {
        NSLayoutConstraint.activate([
            clearButton.topAnchor.constraint(equalTo: cameraPreview.bottomAnchor, constant: 2),
            clearButton.leadingAnchor.constraint(equalTo: cameraPreview.leadingAnchor, constant: 10),
           
        ])
    }
    
    func setupSubmitButtonConstraints() {
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: clearButton.topAnchor),
            submitButton.trailingAnchor.constraint(equalTo: cameraPreview.trailingAnchor, constant: -10),
          
        ])
    }
    func setupReferenceImageViewConstraints() {
        let referenceImageViewContainer = UIView()
        referenceImageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        referenceImageViewContainer.clipsToBounds = true
        view.addSubview(referenceImageViewContainer)
        
        NSLayoutConstraint.activate([
            referenceImageViewContainer.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 5),
            referenceImageViewContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            referenceImageViewContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            referenceImageViewContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        referenceImageView.translatesAutoresizingMaskIntoConstraints = false
        referenceImageViewContainer.addSubview(referenceImageView)
        
        NSLayoutConstraint.activate([
            referenceImageView.centerXAnchor.constraint(equalTo: referenceImageViewContainer.centerXAnchor),
            referenceImageView.centerYAnchor.constraint(equalTo: referenceImageViewContainer.centerYAnchor),
            referenceImageView.widthAnchor.constraint(equalToConstant: 548 / 5.5),
            referenceImageView.heightAnchor.constraint(equalToConstant: 900 / 5.5)
        ])
    }

   
          
      

    func setupHintTextConstraints() {
        // Initially set the constraints assuming `hintText` is positioned below `referenceImageView`
        let topConstraint = hintText.topAnchor.constraint(equalTo: referenceImageView.bottomAnchor, constant: 0)
        let trailingConstraint = hintText.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)

        NSLayoutConstraint.activate([topConstraint, trailingConstraint])

        // Layout the view to apply the initial constraints
        view.layoutIfNeeded()

        // Check if `hintText` bottom is beyond the safe area bottom
        if hintText.frame.minY < view.safeAreaLayoutGuide.layoutFrame.maxY {
            print("should move hint text")
            // If `hintText` is beyond the safe area, adjust the constraints
            NSLayoutConstraint.deactivate([topConstraint])
            NSLayoutConstraint.activate([
                hintText.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                trailingConstraint // reapply the trailing constraint
            ])
        }
    }



    
    func showSpinner() {
        addChild(spinnerChild)
        spinnerChild.view.frame = view.frame
        view.addSubview(spinnerChild.view)
        spinnerChild.didMove(toParent: self)
    }
    
    func hideSpinner() {
        spinnerChild.willMove(toParent: nil)
        spinnerChild.view.removeFromSuperview()
        spinnerChild.removeFromParent()
    }
    
    func setupSophiePhoto() {
        view.addSubview(referenceImageView)
        referenceImageView.translatesAutoresizingMaskIntoConstraints = false
        referenceImageView.isOpaque = true
    }
    
    func setupHintText() {
        view.addSubview(hintText)
        hintText.text = "*Image provided for reference"
        hintText.translatesAutoresizingMaskIntoConstraints = false
        hintText.font = fontType
    }
    
    func setupCameraPreview() {
        view.addSubview(cameraPreview)
        cameraPreview.translatesAutoresizingMaskIntoConstraints = false
        cameraPreview.image = placeholderImage
        cameraPreview.contentMode = .scaleAspectFit
        cameraPreview.tintColor = .label
        let gesture = UITapGestureRecognizer(target: self, action: #selector(previewClicked))
        cameraPreview.isUserInteractionEnabled = true
        cameraPreview.addGestureRecognizer(gesture)
        
        cameraPreview.layer.cornerRadius = 12
        cameraPreview.layer.masksToBounds = true
       
    }
    
    func handlePreviewBorder(_ enable: Bool) {
        if enable {
            cameraPreview.layer.borderWidth = 1
            cameraPreview.layer.borderColor = UIColor.systemGray2.cgColor
        } else {
            cameraPreview.layer.borderWidth = 0
            cameraPreview.layer.borderColor = nil
        }
    }
    
    @objc func previewClicked(sender: UITapGestureRecognizer) {
        if isRunningOnEmulator() {
            displayUserPhoto(UIImage(named: "emulator-photo")!)
            return
        }
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
        cameraVC.allowsEditing = false
        cameraVC.delegate = self
        cameraVC.cameraFlashMode = .off
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        displayUserPhoto(image)
    }
    
    func displayUserPhoto(_ image: UIImage) {
        cameraPreview.image = image
      
        handlePreviewBorder(true)
        
        
        clearButton.alpha = 1
        submitButton.alpha = 1
        view.updateConstraints()
    }
    
    func createClearButton() {
        view.addSubview(clearButton)
        clearButton.setImage(UIImage(systemName: "xmark.circle",withConfiguration: largeConfig), for: .normal)
        clearButton.tintColor = .systemRed
        clearButton.translatesAutoresizingMaskIntoConstraints = false

        clearButton.imageView?.contentMode = .scaleAspectFill
        
        clearButton.addTarget(self, action: #selector(clearImage), for: .touchUpInside)
        clearButton.alpha = 0
    }
    
    func createSubmitButton() {
        view.addSubview(submitButton)
        submitButton.setImage(UIImage(systemName: "checkmark.circle", withConfiguration: largeConfig), for: .normal)
        submitButton.tintColor = .systemGreen
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        
        clearButton.imageView?.contentMode = .scaleAspectFill

        submitButton.alpha = 0
        submitButton.addTarget(self, action: #selector(addPhoto), for: .touchUpInside)
    }
    
    @objc func addPhoto() {
        guard let image = cameraPreview.image else { return }
        
        showSpinner()
        
        let uploadTask = NetworkManager.shared.uploadPhoto(
            image: image,
            progressHandler: { percentComplete in
                print("Upload progress: \(percentComplete)%")
            },
            successHandler: {
                self.hideSpinner()
                print("Upload completed successfully")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Upload Successful", message: "Your photo has been uploaded successfully.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                        self.clearImage()
                    }
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            },
            failureHandler: { error in
                DispatchQueue.main.async {
                    self.hideSpinner()
                    let alert = UIAlertController(title: "Upload Failed", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                switch StorageErrorCode(rawValue: (error as NSError).code)! {
                case .objectNotFound:
                    print("File doesn't exist")
                case .unauthorized:
                    print("User doesn't have permission to access file")
                case .cancelled:
                    print("User canceled the upload")
                case .unknown:
                    print("Unknown error occurred, inspect the server response")
                default:
                    print("A separate error occurred, retry the upload")
                }
            }
        )
        
        _ = uploadTask
    }
    
    @objc func clearImage() {
        cameraPreview.image = placeholderImage
        handlePreviewBorder(false)
        clearButton.alpha = 0
        submitButton.alpha = 0
    }
    
    func tabSelected() {
        // do nothing for now
    }
    
    func isRunningOnEmulator() -> Bool {
        var isEmulator = false
#if targetEnvironment(simulator)
        isEmulator = true
#endif
        return isEmulator
    }
}
