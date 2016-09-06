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
import PopupController
import Cosmos

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var companyImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var categories: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var reviewCount: UILabel!
    var phoneNumber: String?
    var URL: String?
    var latitude: Double?
    var longitude: Double?
    
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var backgroundCardView: UIView!
    
    @IBOutlet weak var detailViewButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var navButton: UIButton!
    
     func updateUI() {
        
        backgroundCardView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        contentView.backgroundColor = UIColor.clearColor()
        
        let pillShape: CGFloat = 45
        let mildRound: CGFloat = 10
        
        backgroundCardView.layer.cornerRadius = mildRound
        backgroundCardView.layer.masksToBounds = true

    }
    
    func bindData(data: Business) {
        
        //Location info
        self.location.text = data.name!
        self.latitude = data.latitude!
        self.longitude = data.longitude!
        
        //Phone number
        if data.phone != nil {
            self.phoneNumber = data.phone!
        } else {
            self.phoneNumber = nil
        }
        
        //Image caching and stylization
        let circleRadius = (self.companyImage.frame.size.height)/2
        self.companyImage.layer.cornerRadius = circleRadius
        self.companyImage.layer.borderWidth = 0
        self.companyImage.layer.masksToBounds = true
        
        if let URLString = data.imageURL?.absoluteString {
            self.companyImage.kf_setImageWithURL(NSURL(string: URLString)!, placeholderImage: UIImage(named: "emptyCell.png"))
        } else {
            self.companyImage.image = UIImage(named: "emptyCell.png")
        }
        
        //Category
        let string = data.categories
        if let range = string!.rangeOfString(",") {
            self.categories.text = ("\(string!.substringToIndex(range.startIndex))  •  \(data.distance!)")
        } else {
            self.categories.text = ("\(data.categories!)  •  \(data.distance!)")
            
        }
        
        //Rating/reviews
        self.reviewCount.text = "\(data.reviewCount!) reviews"
        self.rating.rating = data.rating as! Double
        self.rating.settings.updateOnTouch = false

    }
    
    
    @IBAction func callPhone(sender: AnyObject) {
        self.animateButton(self.phoneButton)
        
        //add UIAlertView to ask for permission to call
        let phoneNumber = self.phoneNumber
        let cleanPhoneNumber = phoneNumber!.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        let alertController = UIAlertController(title: "Call \(self.location.text!)?", message: cleanPhoneNumber, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in }
        
        let callAction = UIAlertAction(title: "Call", style: .Default) { (action) in
            self.callPhone()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(callAction)
        
        //shows the alert on the root view controller
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
    
    @IBAction func showDetail(sender: AnyObject) {
        
        PopupController
            .create(self.parentViewController!)
            .customize(
                [
                    .Animation(.FadeIn),
                    .Scrollable(false),
                    .BackgroundStyle(.BlackFilter(alpha: 0.7))
                ]
            )
            .show(DetailViewController.instance())
    }
    
    
    func animateButton(button: UIButton) {
        
        button.transform = CGAffineTransformMakeScale(0.6, 0.6)
        
        UIView.animateWithDuration(0.2,
                                   delay: 0,
                                   usingSpringWithDamping: CGFloat(0.20),
                                   initialSpringVelocity: CGFloat(6.0),
                                   options: UIViewAnimationOptions.AllowUserInteraction,
                                   animations: {
                                    button.transform = CGAffineTransformIdentity
            },
                                   completion: { Void in()  }
        )
        
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