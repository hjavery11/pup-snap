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

        // Setup `UIPasteControl` configuration
            let pcConfig = UIPasteControl.Configuration()
            pcConfig.baseBackgroundColor = UIColor.blue
            pcConfig.displayMode = UIPasteControl.DisplayMode.iconOnly

            // Create frame and button
            let frameDimension = CGRect(x: 0, y: 0, width: 40, height: 40)
            let bc = BranchPasteControl(frame: frameDimension, andConfiguration: pcConfig)

            // Add `BranchPasteControl()` button to superview
            view.addSubview(bc)
    }


}
