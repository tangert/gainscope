//
//  CustomCell.swift
//  Gainscope
//
//  Created by Tyler Angert on 7/27/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import Cosmos

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var companyImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var categories: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var reviewCount: UILabel!
    
    var phoneNumber: String?
    var latitude: Double?
    var longitude: Double?
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var navButton: UIButton!
    
    @IBOutlet weak var mainConstraint: UILabel!
    @IBOutlet weak var detailConstraint: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.arrangedSubviews.last?.hidden = true
    }
    
    func changeCellStatus(selected: Bool){
        UIView.animateWithDuration(0.5,
                                   delay: 0,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 1,
                                   options: UIViewAnimationOptions.CurveEaseIn,
                                   animations: { () -> Void in
                                    self.stackView.arrangedSubviews.last?.hidden = !selected
            },
                                   completion: nil)
    }
    
    @IBAction func callPhone(sender: AnyObject) {
        self.animateButton(self.phoneButton)
        
        //add UIAlertView to ask for permission to call
        
        let phoneNumber = self.phoneNumber
        let CleanphoneNumber = phoneNumber!.stringByReplacingOccurrencesOfString(" ", withString: "")
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(CleanphoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    @IBAction func bringToMaps(sender: AnyObject) {
        self.animateButton(self.navButton)
        let coordinate = CLLocationCoordinate2DMake(self.latitude!, self.longitude!)
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
        mapItem.name = self.location.text
        mapItem.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        
    }
    
    func animateButton(button: UIButton) {
        
        button.transform = CGAffineTransformMakeScale(0.125, 0.125)
        
        UIView.animateWithDuration(0.25, delay: 0,usingSpringWithDamping: 0.2,
                                   initialSpringVelocity: 9.0,
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: {
                                    button.transform = CGAffineTransformIdentity
            }, completion: nil)
        
    }
}
