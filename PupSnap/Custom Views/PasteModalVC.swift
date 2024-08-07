//
//  PasteModalVC.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/17/24.
//

import UIKit
import BranchSDK

class PasteModalVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureTitle()
        configurePasteControl()
        configureText()
        
        setupSophie()
        
    }
    
    
    
    func setupSophie() {
        let sophie = UIImageView(image: UIImage(named: "sophie-iso"))
        sophie.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sophie)
        
        NSLayoutConstraint.activate([
            sophie.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sophie.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100),
            sophie.widthAnchor.constraint(equalToConstant: 300),
            sophie.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    func configureTitle() {
        title = "Welcome to PupSnap"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.systemPurple]
    }
    
    func configureText() {
        let helper = UILabel()
        helper.text = "You are joining a feed that was shared with you."
        helper.translatesAutoresizingMaskIntoConstraints = false
        helper.textColor = .label
        helper.font = UIFont(name: AppFonts.base.rawValue, size: 20)
        helper.numberOfLines = 2
        //view.addSubview(helper)
        
        
        let instructions = UILabel()
        instructions.text = "Click the button to get started!"
        instructions.font = UIFont(name: AppFonts.base.rawValue, size: 20)
        instructions.translatesAutoresizingMaskIntoConstraints = false
        instructions.textColor = .label
        view.addSubview(instructions)
        
        
        
        NSLayoutConstraint.activate([
            instructions.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            instructions.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            instructions.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
        ])
    }
    
    func configurePasteControl() {
        let pasteControl: UIPasteControl = {
                let pcConfig = UIPasteControl.Configuration()
                pcConfig.baseBackgroundColor = .systemPurple
                pcConfig.baseForegroundColor = .white
                pcConfig.cornerStyle = .capsule
            
                // Three options: icon only, label only, or icon and label
            pcConfig.displayMode = .iconOnly
                let frame = CGRect(x: (view.bounds.width/2.0 - 50), y: (view.bounds.height/2.0 - 100), width: 100, height: 50)
                let pc = UIPasteControl(configuration: pcConfig)
                pc.frame = frame

                self.pasteConfiguration = UIPasteConfiguration(acceptableTypeIdentifiers: [UTType.url.identifier])

                // Very important: must set target so that the overridden `paste(itemProviders)` function gets called
                pc.target = self
                return pc;
            }()
        

        view.addSubview(pasteControl)
      
    }
    
    
    override func paste(itemProviders: [NSItemProvider]) {
            DispatchQueue.main.async { [weak self] in
                self?.navigationController?.dismiss(animated: true)
                if let _ = BNCPasteboard.sharedInstance().checkForBranchLink() {
                    print("found branch pasteboard link, sending to setup")
                    Branch.getInstance().passPaste(itemProviders)                  
                } else {
                    print("found non branch link on pasteboard, sending to regular onboarding")
                    AppDelegate.regularFirstTimeLaunch.send(())
                }
            }
          //Branch.getInstance().passPaste(itemProviders)
    }


}
