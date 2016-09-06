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
import PopupController

class DetailViewController: UIViewController, PopupContentViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let circleRadius = (self.companyImage.frame.size.height)/2
        self.companyImage.layer.cornerRadius = circleRadius
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func instance() -> DetailViewController {
        let storyboard = UIStoryboard(name: "DetailViewController", bundle: nil)
        return storyboard.instantiateInitialViewController() as! DetailViewController
    }
    
    func sizeForPopup(popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        
        let screenBounds = UIScreen.mainScreen().bounds
        let scale = CGAffineTransformMakeScale(0.75, 0.5)
        let size = CGRectApplyAffineTransform(screenBounds, scale)
        let popupSize = size.size
        let screenSize = screenBounds.size
        
        return popupSize
    }
    
    @IBOutlet weak var companyImage: UIImageView!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var categories: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var reviewCount: UILabel!
    
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var phoneButton: UIButton!
    @IBAction func callPhone(sender: AnyObject) {
    }
    
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var navButton: UIButton!
    @IBAction func goToMaps(sender: AnyObject) {
    }
    
    func updateBusinessData(notification: NSNotification) {
        //Location info
        
        var data = notification as! Business
        self.location.text = data.name!
        
        //Phone number
        if data.phone != nil {
            self.phoneNumber.text = data.phone!
        } else {
            self.phoneNumber.text = nil
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layer.cornerRadius = 15

        //add observer notification here
        //change self.business to input business from notification via object pass
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.updateBusinessData(_:)), name: "updateBusinessData", object: nil)
        
        
    }
    
}