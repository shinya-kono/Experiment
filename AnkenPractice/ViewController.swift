//
//  ViewController.swift
//  AnkenPractice
//
//  Created by 河野慎也 on 2019/03/03.
//  Copyright © 2019年 河野慎也. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var helloLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func changeColorClicked(_ sender: Any) {
        helloLabel.textColor = UIColor.red
        
//        let storyboard: UIStoryboard = UIStoryboard(name: "Second", bundle: nil)
        let storyboard: UIStoryboard = UIStoryboard(name: "InputViewTestView", bundle: nil)
        let next: UIViewController = storyboard.instantiateInitialViewController() as! UIViewController
        self.navigationController?.pushViewController(next, animated: true)
//        self.present(next, animated: true, completion: nil)
    }
    
}

