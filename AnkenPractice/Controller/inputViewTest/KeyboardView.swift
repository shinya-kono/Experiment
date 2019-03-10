//
//  KeyboardView.swift
//  AnkenPractice
//
//  Created by 河野慎也 on 2019/03/08.
//  Copyright © 2019年 河野慎也. All rights reserved.
//

import UIKit


protocol KeyboardViewDelegate {
    func keyTapped(sender: KeyboardView, keyNumber: Int)
}

class KeyboardView: UIView, CustomButtonDelegate {
    var delegate: KeyboardViewDelegate!
    
    @IBOutlet weak var button1: CustomButton!
    @IBOutlet weak var button2: CustomButton!
    @IBOutlet weak var button3: CustomButton!
    @IBOutlet weak var button4: CustomButton!
    @IBOutlet weak var button5: CustomButton!
    @IBOutlet weak var button7: CustomButton!
    @IBOutlet weak var button8: CustomButton!
    @IBOutlet weak var button9: CustomButton!
    @IBOutlet weak var button10: CustomButton!
    @IBOutlet weak var button11: CustomButton!
    @IBOutlet weak var button12: CustomButton!
    @IBOutlet weak var button13: CustomButton!
    @IBOutlet weak var button14: CustomButton!
    @IBOutlet weak var button15: CustomButton!
    @IBOutlet weak var button16: CustomButton!
    @IBOutlet weak var button17: CustomButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNib()
        self.setting()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
        self.setting()
    }
    
    func loadNib() {
        let view = Bundle.main.loadNibNamed("Keyboard", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func setting() {
        button1.delegate = self
        button2.delegate = self
        button3.delegate = self
        button4.delegate = self
        button5.delegate = self
        button7.delegate = self
        button8.delegate = self
        button9.delegate = self
        button10.delegate = self
        button11.delegate = self
        button12.delegate = self
        button13.delegate = self
        button14.delegate = self
        button15.delegate = self
        button16.delegate = self
        button17.delegate = self

    }
    
    func customButtonTapped(sender: CustomButton, keyNumber: Int) {
        print("keyNumber = \(keyNumber)")
        delegate.keyTapped(sender: self, keyNumber: keyNumber)
    }
    
    

}
