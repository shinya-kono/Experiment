//
//  CustomImage.swift
//  AnkenPractice
//
//  Created by 河野慎也 on 2019/03/08.
//  Copyright © 2019年 河野慎也. All rights reserved.
//

import UIKit

protocol CustomImageDelegate {
    func doneTapped(sender: CustomImage, keyNumber: Int)
    func cancelTapped(sender: CustomImage)
    func clearTapped(sender: CustomImage)
}

class CustomImage: UIImageView, KeyboardViewDelegate {
    var delegate: CustomImageDelegate!
    var keyNumber: Int = 0
    var keyboardView: KeyboardView
    
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.keyboardView = KeyboardView(frame: CGRect.init(x: 0, y: 0, width: 0, height: 170))
        
        
        super.init(coder: aDecoder)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTouchUpInside(_:))))
        self.keyboardView.delegate = self
    }
    
    @objc func didTouchUpInside(_ sender: UIButton) {
        becomeFirstResponder()
    }
    
    override var inputView: UIView? {
        return keyboardView
    }
    
    override var inputAccessoryView: UIView? {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 44)

        let space = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        space.width = 12
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonTapped(sender:)))
        let clearButton = UIBarButtonItem(title: "クリア", style: .plain, target: self, action: #selector(self.clearButtonTapped(sender:)))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonTapped(sender:)))
        let flexSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let toolbarItems = [space, cancelButton, flexSpaceItem, clearButton, flexSpaceItem, doneButton, space]
        
        toolBar.setItems(toolbarItems, animated: true)
        
        return toolBar
    }
    
    func keyTapped(sender: KeyboardView, keyNumber: Int) {
        self.keyNumber = keyNumber
        self.image = UIImage(named: "sample")
    }
    
    
    @objc func doneButtonTapped(sender: CustomImage) {
        self.resignFirstResponder()
        print("keyNumber = \(keyNumber)")
        delegate.doneTapped(sender: sender, keyNumber: keyNumber)
        
        
    }
    
    @objc func cancelButtonTapped(sender: CustomImage) {
        delegate.cancelTapped(sender: sender)
    }
    
    @objc func clearButtonTapped(sender: CustomImage) {
        delegate.clearTapped(sender: sender)
    }
}
