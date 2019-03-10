//
//  ViewController.swift
//  AnkenPractice
//
//  Created by 河野慎也 on 2019/03/03.
//  Copyright © 2019年 河野慎也. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func textAreaTapped(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "TextView", bundle: nil)
        let next: UIViewController = storyboard.instantiateInitialViewController() as! UIViewController
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @IBAction func symbolTapped(_ sender: Any) {
        let storyboard: UIStoryboard = UIStoryboard(name: "InputViewTestView", bundle: nil)
        let next: UIViewController = storyboard.instantiateInitialViewController() as! UIViewController
        self.navigationController?.pushViewController(next, animated: true)
    }
    
}

