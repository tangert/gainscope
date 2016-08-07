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
    
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var navButton: UIButton!
    

    
    @IBAction func callPhone(sender: AnyObject) {
        self.animateButton(self.phoneButton)
        
        //add UIAlertView to ask for permission to call
        let phoneNumber = self.phoneNumber
        let cleanPhoneNumber = phoneNumber!.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        let alertController = UIAlertController(title: "Call \(self.location.text!)?", message: cleanPhoneNumber, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
        }
        
        alertController.addAction(cancelAction)
        
        let callAction = UIAlertAction(title: "Call", style: .Default) { (action) in
            self.callPhone()
        }
        alertController.addAction(callAction)
        
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)

    }
    
    
    func callPhone() {
        let phoneNumber = self.phoneNumber
        let cleanPhoneNumber = phoneNumber!.stringByReplacingOccurrencesOfString(" ", withString: "")

        if let phoneCallURL:NSURL = NSURL(string: "tel://\(cleanPhoneNumber)") {
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

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.nextResponder()
            if parentResponder is UIViewController {
                return parentResponder as! UIViewController!
            }
        }
        return nil
    }
}

