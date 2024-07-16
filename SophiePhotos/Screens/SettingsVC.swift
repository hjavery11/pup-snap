//
//  SettingsVC.swift
//  SophiePhotos
//
//  Created by Harrison Javery on 7/15/24.
//

import UIKit
import SwiftUI

class SettingsVC: UIViewController {
    
    let settingsView = UIHostingController(rootView: SettingsView())

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
        addChild(settingsView)
        view.addSubview(settingsView.view)
        setupConstraints()
    }
    
    func setupConstraints() {
        settingsView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            settingsView.view.topAnchor.constraint(equalTo: view.topAnchor),
            settingsView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            settingsView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

//extension UIHostingController {
//    convenience public init(rootView: Content, ignoreSafeArea: Bool) {
//        self.init(rootView: rootView)
//
//        if ignoreSafeArea {
//            disableSafeArea()
//        }
//    }
//
//    func disableSafeArea() {
//        guard let viewClass = object_getClass(view) else { return }
//
//        let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
//        if let viewSubclass = NSClassFromString(viewSubclassName) {
//            object_setClass(view, viewSubclass)
//        }
//        else {
//            guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
//            guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }
//
//            if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
//                let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
//                    return .zero
//                }
//                class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
//            }
//
//            if let method2 = class_getInstanceMethod(viewClass, NSSelectorFromString("keyboardWillShowWithNotification:")) {
//                let keyboardWillShow: @convention(block) (AnyObject, AnyObject) -> Void = { _, _ in }
//                class_addMethod(viewSubclass, NSSelectorFromString("keyboardWillShowWithNotification:"), imp_implementationWithBlock(keyboardWillShow), method_getTypeEncoding(method2))
//            }
//
//            objc_registerClassPair(viewSubclass)
//            object_setClass(view, viewSubclass)
//        }
//    }
//}
