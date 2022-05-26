//
//  UIViewController+GestureRecognizer.swift
//  MyFootball
//
//  Created by Raphaël Merrot on 26/05/2022.
//

import UIKit


extension UIViewController {

    func hideKeyboardWhenUnfocused() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }


    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

