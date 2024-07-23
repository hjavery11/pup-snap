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
        
        configurePasteControl()
        configureText()


            
    }
    
    func configureText() {
        let instructions = UILabel()
        instructions.text = "Press here to use app"
        instructions.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructions)
        
        NSLayoutConstraint.activate([
            instructions.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 30),
            instructions.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30)
        ])
    }
    
    func configurePasteControl() {
        let pasteControl: UIPasteControl = {
                let pcConfig = UIPasteControl.Configuration()
                pcConfig.baseBackgroundColor = UIColor(red: 55/255, green: 153/255, blue: 211/255, alpha: 1)
                pcConfig.baseForegroundColor = .white
                pcConfig.cornerStyle = .capsule
            
                // Three options: icon only, label only, or icon and label
            pcConfig.displayMode = .iconOnly
                let frame = CGRect(x: 20 , y: 60, width: 40, height: 40)
                let pc = UIPasteControl(configuration: pcConfig)
                pc.frame = frame

                self.pasteConfiguration = UIPasteConfiguration(acceptableTypeIdentifiers: [UTType.url.identifier])

                // Very important: must set target so that the overridden `paste(itemProviders)` function gets called
                pc.target = self
                return pc;
            }()
        pasteControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pasteControl)
        
        NSLayoutConstraint.activate([
            pasteControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pasteControl.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    
    override func paste(itemProviders: [NSItemProvider]) {
        if #available(iOS 16.0, *) {
            navigationController?.dismiss(animated: true)
            print("paste was passed for \(itemProviders)")
            LaunchManager.shared.initializePasteboardBranch()
           // Branch.getInstance().passPaste(itemProviders)
        } else {
            // Fallback on earlier versions
        }
    }


}
