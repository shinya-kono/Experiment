//
//  CustomButton.swift
//  AnkenPractice
//
//  Created by 河野慎也 on 2019/03/10.
//  Copyright © 2019年 河野慎也. All rights reserved.
//

import UIKit

protocol CustomButtonDelegate {
    func customButtonTapped(sender: CustomButton, keyNumber: Int)
}

class CustomButton: UIButton {
    @IBInspectable var keyNumber: Int = 0
    var delegate: CustomButtonDelegate!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        self.addTarget(self, action: #selector(self.didTapped), for: .touchUpInside)
        self.imageView?.contentMode = .scaleAspectFit
    }
    
    @objc func didTapped(sender: CustomButton) {
        delegate.customButtonTapped(sender: sender, keyNumber: self.keyNumber)
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.gray : UIColor.white
        }
    }
}
