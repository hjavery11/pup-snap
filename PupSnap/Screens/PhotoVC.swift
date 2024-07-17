//
//  PhotoVC.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/1/24.
//
import UIKit
import SwiftUI
import FirebaseStorage

class PhotoVC: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PhotoEditorVCDelegate, ObservableObject {
    
    let hintText = UILabel()
    let dog = UIImageView()
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
    let largeConfig = UIImage.SymbolConfiguration(pointSize: 44, weight: .bold, scale: .default)
    
    var fontType: UIFont?
    var largeTitleFontSize: CGFloat?
    let deviceWidth = UIScreen.main.bounds.width
    
    var placeholderImage = UIImage(systemName: "photo")
    
    var lineView: LineView?
    var speechBubbleHostingController: UIHostingController<SpeechBubbleView>?
    
    // Reference to the height constraint of referenceImageView
    var referenceImageViewHeightConstraint: NSLayoutConstraint?
   
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        
        setDogInfo()
        
        // set font size depending on screen width to fit title and hint text
        setFontSize()
        setNavigationBarTitle()
        // views
        setupCameraView()
        setupDogPhoto()
        setupSpeechBubble()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        setDogInfo()
    }
    
    func setDogInfo() {
        let dogName = PersistenceManager.getDogName() ?? "Sophie"
        let icon = PersistenceManager.getDogPhoto() ?? "sophie-iso"
        let text = "Hi, I'm \(dogName).\nTap on me to add a photo!"
        
        dog.image = UIImage(named: icon)
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
        view.addSubview(dog)
        dog.translatesAutoresizingMaskIntoConstraints = false
        
        // Assuming the original image size is available, use its aspect ratio.
        if let image = dog.image {
            let aspectRatio = image.size.width / image.size.height
            NSLayoutConstraint.activate([
                dog.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                dog.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                dog.widthAnchor.constraint(equalToConstant: 300),
                dog.heightAnchor.constraint(equalTo: dog.widthAnchor, multiplier: 1/aspectRatio) // Maintain aspect ratio
            ])
        }
        
        dog.contentMode = .scaleAspectFit
        dog.clipsToBounds = true
        
        // load full screen photo view when image is tapped
        let gesture = UITapGestureRecognizer(target: self, action: #selector(dogClicked))
        dog.isUserInteractionEnabled = true
        dog.addGestureRecognizer(gesture)
    }
    
    func updateDogPhoto(newDog: UIImage) {
        dog.image = newDog
        
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
            hostingController.view.bottomAnchor.constraint(equalTo: dog.topAnchor, constant: -padding)
        ])
        
        hostingController.didMove(toParent: self)
        self.speechBubbleHostingController = hostingController
        
    }
    
    func setNavigationBarTitle() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: largeTitleFontSize ?? 12, weight: .bold),
            NSAttributedString.Key.foregroundColor: UIColor.systemPurple
        ]
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
    
    func setFontSize() {
        // set font size based off width of screen
        if deviceWidth > 375 {
            largeTitleFontSize = 34
            fontType = UIFont.systemFont(ofSize: 12)
        } else {
            largeTitleFontSize = 28
            fontType = UIFont.systemFont(ofSize: 10)
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
    
    @objc func dogClicked(sender: UITapGestureRecognizer) {
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
    
    func photoEditorDidRequestCamera(_ editor: PhotoEditorVC) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            editor.dismiss(animated: true)
            present(cameraVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "No Camera", message: "Camera is not available on this device", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    func photoEditorDidUpload(_ editor: PhotoEditorVC) {
        showSpinner()
        
        Task {
            do {
                let isWithinLimit = try await NetworkManager.shared.checkPhotoLimit()
                
                if isWithinLimit {
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
    
    func setupCrashButton() {
        let crashButton = CrashlyticsCrashButton()
        crashButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(crashButton)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            crashButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            crashButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            crashButton.widthAnchor.constraint(equalToConstant: 100),
            crashButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
}

//keeping this here because it took a while to figure out how to draw a line between 2 view points, so in case I go back to this method

//func addLineView() {
//        let lineView = LineView()
//        lineView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(lineView)
//        self.lineView = lineView
//
//        // The lineView should not interfere with the layout of other views.
//        NSLayoutConstraint.activate([
//            lineView.topAnchor.constraint(equalTo: view.topAnchor),
//            lineView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//            lineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            lineView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//        ])
//
//        // Initial update of the line view
//        updateLineView()
//    }
//
//    func updateLineView() {
//        guard let lineView = lineView,
//              let speechBubbleView = speechBubbleHostingController?.view else { return }
//
//        // Convert the center points of both views to the coordinate space of the `lineView`
//        let sophieCenterInLineView = sophie.convert(CGPoint(x: sophie.bounds.midX, y: sophie.bounds.midY), to: lineView)
//        let bubbleCenterInLineView = speechBubbleView.convert(CGPoint(x: speechBubbleView.bounds.midX, y: speechBubbleView.bounds.midY), to: lineView)
//
//        print("Sophie Center: \(sophieCenterInLineView)")
//        print("Bubble Center: \(bubbleCenterInLineView)")
//
//        lineView.setPoints(start: sophieCenterInLineView, end: bubbleCenterInLineView)
//    }
