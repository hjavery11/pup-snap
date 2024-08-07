//
//  PhotoVC.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/1/24.
//
import UIKit
import SwiftUI
import FirebaseStorage
import PhotosUI
import Photos

class PhotoVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoEditorVCDelegate, ObservableObject, PHPickerViewControllerDelegate {
    
    let hintText = UILabel()
    let dogImage = UIImageView()
    @Published var speechBubbleText = "Initial text"
    let bubbleConnect = UIImageView(image: UIImage(named: "bubble-connector"))
    let emulatorPhoto = UIImage(named: "emulator-photo")
    let cameraPreview = UIImageView()
    let cameraVC = UIImagePickerController()
    let clearButton = UIButton()
    let submitButton = UIButton()
    let spinnerChild = SpinnerVC()
    
    let imageWidth: CGFloat = 85 * 3 // easily keep the 3:4 ratio using a base value
    let imageHeight: CGFloat = 85 * 4
    
    let buttonFont: CGFloat = 16

    let deviceWidth = UIScreen.main.bounds.width
    
    var placeholderImage = UIImage(systemName: "photo")
    
    var lineView: LineView?
    var speechBubbleHostingController: UIHostingController<SpeechBubbleView>?
    
    // Reference to the height constraint of referenceImageView
    var referenceImageViewHeightConstraint: NSLayoutConstraint?
    
    //success toast
    private let successToastVC = UIHostingController(rootView: SuccessToast())
    private var bottomConstant: NSLayoutConstraint?
    
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    var activePhotoOption:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        // set font size depending on screen width to fit title and hint text
        setDogInfo()
        setupDogPhoto()

        setNavigationBarTitle()
        
        // views
        setupCameraView()
        setupSpeechBubble()
        
        configureSuccessToast()
        
        configureActionSheet()
      
    }    
    
    override func viewDidAppear(_ animated: Bool) {
        if LaunchManager.shared.showToast {
            showSwiftUIToast()
            LaunchManager.shared.showToast = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if LaunchManager.shared.dogChanged {
            setNewDog()
            LaunchManager.shared.dogChanged = false
        }
        print("setting photo vc loaded to true")
        LaunchManager.shared.photoVCLoaded = true
    }
    
    func setNewDog() {
        guard let _ = LaunchManager.shared.dog else {
            print("no current dog set")
            return
        }
        
        print("checking for photo VC loaded in setNewDog")
        
        if LaunchManager.shared.photoVCLoaded {
            dogImage.removeFromSuperview()
            bubbleConnect.removeFromSuperview()
            speechBubbleHostingController?.view.removeFromSuperview()
            
            setDogInfo()
            setupDogPhoto()
            setupSpeechBubble()
            
            //Setting bg color again because of weird bug where it doesnt get set after re creating hosting controller
            speechBubbleHostingController?.view.backgroundColor = .systemGray6
        }
    }
    
    func setDogInfo() {
        guard let currentDog = LaunchManager.shared.dog else {
            print("Could not find current dog in launch manager")
            return
        }
        
        var text: String
        
        if currentDog.name.count < 21 {
            text = "Hi, I'm \(currentDog.name).\nTap on me to add a photo!"
        } else {
            let shortName = currentDog.name[0..<18]
           text = "Hi, I'm \(shortName)...\nTap on me to add a photo!"
        }
     
        
        dogImage.image = UIImage(named: currentDog.photo)
        self.speechBubbleText = text
        updateSpeechBubbleText(text)
    }
    
    func updateSpeechBubbleText(_ text: String) {
        speechBubbleText = text
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConnector()
    }
    
    func setupDogPhoto() {
        view.addSubview(dogImage)
        dogImage.translatesAutoresizingMaskIntoConstraints = false
        
        // Assuming the original image size is available, use its aspect ratio.
        if let _ = dogImage.image {
            let targetWidth: CGFloat = view.bounds.width
          
            NSLayoutConstraint.activate([
                dogImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                dogImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                dogImage.widthAnchor.constraint(equalToConstant: targetWidth),
                dogImage.heightAnchor.constraint(equalToConstant: targetWidth)
            ])
        }
        
        dogImage.contentMode = .scaleAspectFit
        dogImage.clipsToBounds = true
        
        // load full screen photo view when image is tapped
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dogClicked))
        dogImage.isUserInteractionEnabled = true
        dogImage.addGestureRecognizer(gesture)
    }
    
    func updateDogPhoto(newDog: UIImage) {
        dogImage.image = newDog
    }
    
    func setupSpeechBubble() {
        // show the SwiftUI speech bubble
        let hostingController = UIHostingController(rootView: SpeechBubbleView(vm: self))
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        
        let padding: CGFloat = 10
           NSLayoutConstraint.activate([
               hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
               hostingController.view.bottomAnchor.constraint(equalTo: dogImage.topAnchor, constant: -20),
           ])
           
           hostingController.didMove(toParent: self)
           self.speechBubbleHostingController = hostingController
    }
    
    func setupConnector() {
        guard let speechBubbleHostingController = self.speechBubbleHostingController else { return }
        
        view.addSubview(bubbleConnect)
        bubbleConnect.translatesAutoresizingMaskIntoConstraints = false
        
        if let image = bubbleConnect.image {
            let aspectRatio = image.size.width / image.size.height
            NSLayoutConstraint.activate([
                bubbleConnect.centerXAnchor.constraint(equalTo: speechBubbleHostingController.view.centerXAnchor),
                bubbleConnect.topAnchor.constraint(equalTo: speechBubbleHostingController.view.bottomAnchor),
                bubbleConnect.widthAnchor.constraint(equalToConstant: 30),
                bubbleConnect.heightAnchor.constraint(equalTo: bubbleConnect.widthAnchor, multiplier: 1/aspectRatio) // Maintain aspect ratio
            ])
        }
    }
    
    func setNavigationBarTitle() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont(name: AppFonts.bold.rawValue, size: 35)!,
            NSAttributedString.Key.foregroundColor: AppColors.appPurple
        ]
        
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
    
    @objc func dogClicked(sender: UITapGestureRecognizer) {
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            present(cameraVC, animated: true)
        } else {
            let alert = UIAlertController(title: "No Camera Access", message: "Please allow access to the camera in settings in order to take a photo.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func pickPhotos()
    {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = PHPickerFilter.images
        
        let pickerViewController = PHPickerViewController(configuration: config)
        pickerViewController.delegate = self
        DispatchQueue.main.async {
            self.present(pickerViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: PHPickerViewControllerDelegate
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        self.displayImage(image)
                    }
                }
            })
        }
    }
    
    func configureActionSheet() {
        
        let cameraOption = UIAlertAction(title: "Take new photo", style: .default) { _ in
            self.showCamera()
            self.activePhotoOption = "camera"
        }
        let libraryOption = UIAlertAction(title: "Upload from library", style: .default) { _ in
            self.pickPhotos()
            self.activePhotoOption = "library"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(cameraOption)
        actionSheet.addAction(libraryOption)
        actionSheet.addAction(cancel)
    }
    
    func setupCameraView() {
        cameraVC.sourceType = .camera
        cameraVC.allowsEditing = false
        cameraVC.delegate = self
        cameraVC.cameraFlashMode = .off
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true) {
            self.displayImage(image)
        }
    }
    
    func displayImage(_ image: UIImage) {
        let editVC = PhotoEditorVC(image: image)
        editVC.delegate = self
        editVC.modalPresentationStyle = .fullScreen
        self.present(editVC, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        // only for testing purposes
        if isRunningOnEmulator() {
            displayImage(emulatorPhoto!)
            return
        }
    }
    
    func photoEditorDidRequestBack(_ editor: PhotoEditorVC) {
        if activePhotoOption == "camera" {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                editor.dismiss(animated: true)
                present(cameraVC, animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "No Camera", message: "Camera is not available on this device", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        } else if activePhotoOption == "library" {
            editor.dismiss(animated: true)            
        } else {
            print("no active photo option set, cant present back")
            editor.dismiss(animated: true)
        }
    }
    
    func checkPhotoSize(for image: UIImage) throws -> Bool {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            print("Failed to get image data")
            throw NSError(domain: "PhotoVC", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unable to get image data"])
        }
        
        let imageSizeInBytes = imageData.count
        let imageSizeinMB = Double(imageSizeInBytes) / 1048576.0
        
        let maxFileSizeinMB = Double(5.0)
        
        print("file size is \(imageSizeinMB)")
        
        if imageSizeinMB > maxFileSizeinMB {
            print("file size exceed maximum file size of \(maxFileSizeinMB) mb")
            throw NSError(domain: "PhotoVC", code: 1, userInfo: [NSLocalizedDescriptionKey: "Image file exceeds maximum allowable size of \(maxFileSizeinMB) MB"])
        }
        
        return true
    }
    
    func photoEditorDidUpload(_ editor: PhotoEditorVC) {
        showSpinner()
        Task { @MainActor in
            do {
                let isWithinLimit = try await NetworkManager.shared.checkPhotoLimit()
                
                let isWithinSize = try self.checkPhotoSize(for: editor.image)
                
                if isWithinLimit && isWithinSize {
                    let image = editor.image
                    let caption = editor.captionField.text ?? ""
                    let user = PersistenceManager.retrieveID()
                    let rating = editor.cuteScale.rating
                    let ratings = [user: rating]
                    let photoID = UUID().uuidString
                    
                    let photo = Photo(caption: caption, ratings: ratings, timestamp: Int(Date().timeIntervalSince1970), image: image, id: photoID)
                    
                    let _ = NetworkManager.shared.uploadPhoto(
                        photo: photo,
                        progressHandler: { percentComplete in
                            print("Upload progress: \(percentComplete)%")
                        },
                        successHandler: { [weak self] in
                            guard let self = self else { return }
                            self.hideSpinner()
                            print("Upload completed successfully")
                            Task{
                                try await DatabaseHelper().addPhotoToDB(photo: photo)
                            }
                            
                            DispatchQueue.main.async {
                                let alert = UIAlertController(title: "Upload Successful", message: "Your photo has been uploaded successfully.", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: .default)
                                alert.addAction(okAction)
                                self.present(alert, animated: true, completion: nil)
                            }
                        },
                        failureHandler: { [weak self] error in
                            guard let self = self else { return }
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
                            case .downloadSizeExceeded:
                                print("Image size exceeded maximum image size of 5 mb")
                            default:
                                print("A separate error occurred, retry the upload")
                            }
                        }
                    )
                }
            } catch let error as NSError {
                self.hideSpinner()
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Upload Failed", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
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
    
    private func configureSuccessToast() {
        addChild(successToastVC)
        successToastVC.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(successToastVC.view)
        successToastVC.didMove(toParent: self)
        
        successToastVC.view.backgroundColor = .clear
        
        bottomConstant = successToastVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 500)
        
        NSLayoutConstraint.activate([
            bottomConstant!,
            successToastVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            successToastVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15)
        ])
    }
    
    private func showSwiftUIToast() {
        bottomConstant?.constant = -100
        
        
        UIView.animateKeyframes(withDuration: 4, delay: 0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
            
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                self.bottomConstant?.constant = 500
                self.view.layoutIfNeeded()
            }
        })
    }
    
}
