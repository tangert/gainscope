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
import EasyTransition
import NotificationCenter
import Kingfisher
import UberRides
import Cosmos

class CustomCell: UITableViewCell {
    
    var transition: EasyTransition?
    var setImageWithAnimate: (UIImage->Void)!
    var business: Business?
    var searchTerm: String?
    
    @IBOutlet weak var companyImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var categories: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var reviewCount: UILabel!
    var phoneNumber: String?
    var URL: String?
    var latitude: Double?
    var longitude: Double?
    
    @IBOutlet weak var backgroundCardView: UIView!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var navButton: UIButton!
    @IBOutlet weak var detailButton: UIButton!
        
     func updateUI() {
        
        detailButton.tintColor = UIColor.lightGrayColor()
        backgroundCardView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        contentView.backgroundColor = UIColor.clearColor()
        
        let pillShape: CGFloat = 45
        let mildRound: CGFloat = 10
        
        backgroundCardView.layer.cornerRadius = mildRound
        backgroundCardView.layer.masksToBounds = true

    }
    
    func bindData(data: Business) {
        
        //setting business data to store for detail view.
        self.business = data
        //self.searchTerm =
        
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
        
        updateImage(data)
        
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
    
    func updateImage(business: Business?) {
        
        if business!.name == "Starbucks" {
            companyImage.image = UIImage(named: "starbucksbig")
        }
            
        else if business!.name == "Dunkin' Donuts" {
            companyImage.image = UIImage(named: "dunkinbig")
        }
            
        else if business!.name!.rangeOfString("Chipotle") != nil {
            companyImage.image = UIImage(named: "chipotlebig")
        }
            
        else if business!.name!.rangeOfString("CrossFit") != nil
            || business!.name!.rangeOfString("Crossfit") != nil {
            companyImage.image = UIImage(named: "crossfitbig")
            
        } else if business!.name!.rangeOfString("YMCA") != nil {
            companyImage.image = UIImage(named: "ymcabig")
            
        }
            
        else if business!.name!.rangeOfString("24") != nil {
            companyImage.image = UIImage(named: "24hourbig")
        }
            
            //special asian food map pin
        else if business!.categories!.rangeOfString("Sushi") != nil ||
            business!.categories!.rangeOfString("Korean") != nil ||
            business!.categories!.rangeOfString("Chinese") != nil ||
            business!.categories!.rangeOfString("Thai") != nil ||
            business!.categories!.rangeOfString("Japanese") != nil ||
            business!.categories!.rangeOfString("Taiwanese") != nil ||
            business!.categories!.rangeOfString("Ramen") != nil ||
            business!.categories!.rangeOfString("Asian") != nil
        {
            companyImage.image = UIImage(named: "asianbig")
        }
        
        else {
            if let URLString = business!.imageURL?.absoluteString {
                self.companyImage.kf_setImageWithURL(NSURL(string: URLString)!, placeholderImage: UIImage(named: "emptyCell.png"))
            } else {
                self.companyImage.image = UIImage(named: "emptyCell.png")
            }
        }
        
    }
    
    
    @IBAction func showDetail(sender: AnyObject) {
        print(self.business?.name)
        //NSNotificationCenter.defaultCenter().postNotificationName("showDetailView", object: self.business)
        
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("DetailViewController") as! DetailViewController
        
        detailVC.business = business
        detailVC.searchTerm = business?.searchTerm
        
        transition = EasyTransition(attachedViewController: detailVC)
        transition?.transitionDuration = 0.3
        transition?.direction = .Bottom
        
        let leftRightMargins = ((self.parentViewController?.view.frame.width)!/(10*1.5))
        let topBottomMargins = ((self.parentViewController?.view.frame.height)!/(10*0.5))
        
        transition?.margins = UIEdgeInsets(top: topBottomMargins, left: leftRightMargins, bottom: topBottomMargins, right: leftRightMargins)
        
        transition?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.65)
        
        detailVC.view.layer.cornerRadius = 20
        UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(detailVC, animated: true, completion: nil)
        
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