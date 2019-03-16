//
//  ShowQRInfoViewController.swift
//  AnkenPractice
//
//  Created by 河野慎也 on 2019/03/16.
//  Copyright © 2019年 河野慎也. All rights reserved.
//

import UIKit

class ShowQRInfoViewController: UIViewController {
    
    let readedSymbols: [StructuralConnectionInfo]
    let label = UILabel()
    
    
    init(readedSymbols: [StructuralConnectionInfo]) {
        self.readedSymbols = readedSymbols
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        
        self.view.addSubview(self.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        self.label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        self.label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        self.label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.white
        
        self.label.textColor = UIColor.black
        self.label.numberOfLines = 0
        
        var strings = ""
        
        readedSymbols.map{$0.string}.forEach { (string) in
            print("string = \(string)")
            
            
            
            strings += string!
        }
        
        self.label.text = strings
    }
}
