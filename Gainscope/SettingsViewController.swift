//
//  SettingsViewController.swift
//  Gainscope
//
//  Created by Tyler Angert on 9/5/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import Foundation
import UIKit
import TagListView


class SettingsViewController: UIViewController {
    
    var imageDidSelected: (UIImage->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var coffeeInput: UITextField!
    @IBOutlet weak var gymsInput: UITextField!
    @IBOutlet weak var foodInput: UITextField!
    
    
    
    
}