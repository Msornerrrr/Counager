//
//  File.swift
//  JiangRichardFinalProject
//
//  Created by XuGX on 2022/12/4.
//

import UIKit

// extend the UIViewController, add keyboard dismiss functionality
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tapBackground = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tapBackground.cancelsTouchesInView = false
        view.addGestureRecognizer(tapBackground)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
