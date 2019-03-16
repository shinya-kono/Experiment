//
//  AnimationViewController.swift
//  AnkenPractice
//
//  Created by 河野慎也 on 2019/03/11.
//  Copyright © 2019年 河野慎也. All rights reserved.
//

import UIKit

class AnimationViewController: UIViewController {
    @IBOutlet weak var animationLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        
        guard sender.markedTextRange == nil else {
            return
        }
        
        guard let text = sender.text else { return }
        
        
        let range = sender.selectedTextRange
        
        sender.text = text.applyingTransform(.fullwidthToHalfwidth, reverse: true)
        
        sender.selectedTextRange = range
        
        
        
        if text.count > 10 {
            UIView.animate(withDuration: 0.5) {
                self.animationLabel.isHidden = false
//                self.stackView.layoutIfNeeded()
            }
            
            
        } else {
            UIView.animate(withDuration: 0.5) {
                self.animationLabel.isHidden = true
//                self.stackView.layoutIfNeeded()3214
            }
        }
        
        
    }
    @IBAction func buttonTapped(_ sender: Any) {
        if animationLabel.isHidden {
            UIView.animate(withDuration: 0.5) {
                self.animationLabel.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.5) {
                self.animationLabel.isHidden = true
            }
        }
    }
}
