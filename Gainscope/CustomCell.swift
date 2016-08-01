//
//  CustomCell.swift
//  Gainscope
//
//  Created by Tyler Angert on 7/27/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var companyImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var categories: UILabel!
    
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var reviewCount: UILabel!
    
    @IBAction func callPhone(sender: AnyObject) {
        
        
        
    }
    
    @IBAction func bringToMaps(sender: AnyObject) {
        
        
        
    }
}
