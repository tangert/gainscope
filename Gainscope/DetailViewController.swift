//
//  DetailViewController.swift
//  Gainscope
//
//  Created by Tyler Angert on 8/20/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import Foundation
import UIKit
import UberRides
import MapKit
import Cosmos
import Kingfisher
import NVActivityIndicatorView
import Async

class DetailViewController: UIViewController {
    
    var business: Business?
    var searchTerm: String?
    var latitude: CLLocationDegrees?
    var longitude: CLLocationDegrees?
    
    @IBOutlet weak var companyImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var categories: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var reviewCount: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var navButton: UIButton!
    
    @IBOutlet weak var bottomStack: UIStackView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var locationData = PrimaryContentViewController.sharedInstance.locationManager
    let button = RideRequestButton()
    let ridesClient = RidesClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateBusinessData(business)
        
        let circleRadius = (self.companyImage.frame.size.height)/2
        companyImage.layer.cornerRadius = circleRadius
        
        self.view.layer.cornerRadius = 15
        
        button.colorStyle = .Black
        let userLatitude = (self.locationData.location?.coordinate.latitude)!
        let userLongitude = (self.locationData.location?.coordinate.longitude)!
        let pickupLocation = CLLocation(latitude: userLatitude, longitude: userLongitude)
        
        let dropoffLocation = CLLocation(latitude: business!.latitude!, longitude: business!.longitude!)
        
        let builder = RideParametersBuilder().setPickupLocation(pickupLocation).setDropoffLocation(dropoffLocation)
        
        builder.setPickupLocation(pickupLocation).setDropoffLocation(dropoffLocation, nickname: business!.name!, address: business!.address!)
        
        ridesClient.fetchCheapestProduct(pickupLocation: pickupLocation, completion: {
            product, response in
            if let productID = product?.productID { //check if the productID exists
                builder.setProductID(productID)
                self.button.rideParameters = builder.build()
                // show estimates in the button
                self.button.loadRideInformation()
            }
        })
        
        self.view.addSubview(button)
        
        button.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view!).offset(330)
            make.left.equalTo(self.view!).offset(20)
            make.bottom.equalTo(self.view!).offset(-20)
            make.right.equalTo(self.view!).offset(-20)
        }
        
        companyImage.snp_makeConstraints { (make) in
            
            make.top.equalTo(self.view!).offset(-65)
        }

    }
    
    
    func updateBusinessData(business: Business?) {
        //Location info
        if let data = business {
            bindData(data)
        }
    }
    
    
    var hasPhone = true
    
    func bindData(data: Business) {
        
        latitude = data.latitude!
        longitude = data.longitude!
        
        location.text = data.name!
        print("Location from databinding: \(location.text!)")
        
        
        if data.phone != nil {
            self.phoneLabel.text = data.phone!
            } else {
                self.phoneLabel.text = "No phone!"
                hasPhone = false
        }
        
        let addressString = data.address
        if let addressRange = addressString!.rangeOfString(",") {
            addressLabel.text = ("\(addressString!.substringToIndex(addressRange.startIndex))")
        } else {
            addressLabel.text = ("\(data.address!)")
        }
        
        self.addressLabel.text = data.address!
        
        //Image caching and stylization
        let circleRadius = (self.companyImage.frame.size.height)/2
        companyImage.layer.cornerRadius = circleRadius
        companyImage.layer.borderWidth = 0
        companyImage.layer.masksToBounds = true
        updateImage(data)
        
        //Category
        let string = data.categories
        if let range = string!.rangeOfString(",") {
            categories.text = ("\(string!.substringToIndex(range.startIndex))  •  \(data.distance!)")
        } else {
            categories.text = ("\(data.categories!)  •  \(data.distance!)")
        }
        
        //Rating/reviews
        reviewCount.text = "\(data.reviewCount!) reviews"
        rating.rating = data.rating as! Double
        rating.settings.updateOnTouch = false
        
        
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
            print("Searchterm: " + searchTerm!)
            print("Image name: \(searchTerm!)big")
            companyImage.image = UIImage(named:
                "\(searchTerm!)big")
        }
    }
    
    @IBAction func callPhone(sender: AnyObject) {
    
        if hasPhone == true {
        self.animateButton(self.phoneButton)
        
        //add UIAlertView to ask for permission to call
        let phoneNumber = self.phoneLabel.text!
        let cleanPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        let alertController = UIAlertController(title: "Call \(self.location.text!)?", message: cleanPhoneNumber, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in }
        
        let callAction = UIAlertAction(title: "Call", style: .Default) { (action) in
            self.callPhone()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(callAction)
        
        //shows the alert on the root view controller
        self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            
            let alertController = UIAlertController(title: "Uh oh! No phone number!", message: "Sorry about that.", preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Alright", style: .Cancel) { (action) in }
            
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)

        }
    
    }

    func callPhone() {
        let phoneNumber = self.phoneLabel.text!
        let cleanPhoneNumber = phoneNumber.stringByReplacingOccurrencesOfString(" ", withString: "")
        
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(cleanPhoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }
    
    @IBAction func goToMaps(sender: AnyObject) {
        
        animateButton(navButton)
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
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}