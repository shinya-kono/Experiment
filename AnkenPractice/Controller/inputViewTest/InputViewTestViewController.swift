//
//  InputViewTestViewController.swift
//  AnkenPractice
//
//  Created by 河野慎也 on 2019/03/08.
//  Copyright © 2019年 河野慎也. All rights reserved.
//

import UIKit

class InputViewTestViewController: UIViewController, CustomImageDelegate {
    
    @IBOutlet weak var imageView: CustomImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.imageView.becomeFirstResponder()
        self.title = "エンジンオイルの漏れあああああああああああああ"
    }
    
    func doneTapped(sender: CustomImage, keyNumber: Int) {
        print("keyNumber = \(keyNumber)")
        self.navigationController?.popViewController(animated: true)
    }
    
    func cancelTapped(sender: CustomImage) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func clearTapped(sender: CustomImage) {
        self.imageView.resignFirstResponder()
//        self.navigationController?.popViewController(animated: true)
    }
    
}
