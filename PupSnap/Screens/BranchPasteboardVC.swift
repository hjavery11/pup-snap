//
//  BranchPasteboardVC.swift
//  PupSnap
//
//  Created by Harrison Javery on 7/23/24.
//

import UIKit

class BranchPasteboardVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let textView = UITextView(frame: view.bounds)
        view.addSubview(textView)


        let configuration = UIPasteControl.Configuration()
        configuration.baseBackgroundColor = .red
        configuration.baseForegroundColor = .magenta
        configuration.cornerStyle = .capsule
        configuration.displayMode = .iconAndLabel
                            
        let pasteButton = UIPasteControl(configuration: configuration)
        pasteButton.frame = CGRect(x: view.bounds.width/2.0, y: view.bounds.height/2.0, width: 150, height: 60)
        textView.addSubview(pasteButton)


        pasteButton.target = textView
    }
    

   

}
