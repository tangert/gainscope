//
//  ViewController.swift
//  gainscope
//
//  Created by Tyler Angert on 6/28/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import AddressBookUI
import AFNetworking
import Async
import NotificationCenter

class PrimaryContentViewController: UIViewController, MKMapViewDelegate, PulleyPrimaryContentControllerDelegate, LocationUpdateProtocol {
    
    static let sharedInstance = PrimaryContentViewController()
    
    var yelpClient: YelpClient!
    let yelpConsumerKey = "uDLkplNRgQcI9sM0CMnHxg"
    let yelpConsumerSecret = "2-34WuoVmOzCEs8NNWrdW0oAECc"
    let yelpToken = "yULdo-JwtBGgi1uNRvW-Yprll86x2JlU"
    let yelpTokenSecret = "wvgz30HjKdqR9Ul0qKSyDd4ASCM"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let yc = DataManager.sharedInstance
        yc.yelpClient = YelpClient(consumerKey: yc.yelpConsumerKey, consumerSecret: yc.yelpConsumerSecret, accessToken: yc.yelpToken, accessSecret: yc.yelpTokenSecret)

        //Initial button setup
        self.buttonBackground.layer.cornerRadius = 20
        self.buttonBackground.clipsToBounds = true
        self.centerButtonBackground.layer.cornerRadius = 20
        self.centerButtonBackground.clipsToBounds = true
        
        let coffeeImage : UIImage = UIImage(named: "coffeeUnfilledGrey.png")!
        let gymsImage: UIImage = UIImage(named: "gymsUnfilledGrey.png")!
        let foodImage: UIImage = UIImage(named: "foodUnfilledGrey.png")!
        self.coffeeButton.setImage(coffeeImage, forState: .Normal)
        self.gymsButton.setImage(gymsImage, forState: .Normal)
        self.foodButton.setImage(foodImage, forState: .Normal)
        
        
        //map setup
        self.map.delegate = self
        self.map.showsUserLocation = true
//        
//        if let location = self.currentLocation {
//            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
//            self.map.setRegion(region, animated: true)
//        }

        //user location
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PrimaryContentViewController.locationUpdateNotification(_:)), name: kLocationDidChangeNotification, object: nil)
        
        let locationMgr = UserLocationManager.sharedManager
        locationMgr.delegate = self
        
        self.data.performSearches()
        
        //map data
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PrimaryContentViewController.updateMapData(_:)) , name: "updataMapData", object: nil)
        
    }

    var currentLocation : CLLocation!

    // MARK: - Notifications
    func locationUpdateNotification(notification: NSNotification) {
        let userinfo = notification.userInfo
        self.currentLocation = userinfo!["location"] as! CLLocation
        
        //let region = region
        print("Latitude : \(self.currentLocation.coordinate.latitude)")
        print("Longitude : \(self.currentLocation.coordinate.longitude)")
        
    }
    
    func updateMapData(notification: NSNotification) {
        
        //print("Notfication from PrimaryView sent. ListItem Count: \(DataManager.sharedInstance.listItems.count)")
    }
    
    // MARK: - LocationUpdateProtocol
    func locationDidUpdateToLocation(location: CLLocation) {
        currentLocation = location
        print("Latitude : \(self.currentLocation.coordinate.latitude)")
        print("Longitude : \(self.currentLocation.coordinate.longitude)")
    }
    
    var locationFound = true
    
    //button and map initializations
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var coffeeButton: UIButton!
    @IBOutlet weak var gymsButton: UIButton!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var buttonBackground: UIView!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var centerButtonBackground: UIVisualEffectView!
    @IBOutlet weak var buttonsBottomConstraint: NSLayoutConstraint!
    private let buttonsBottomDistance: CGFloat = 0.0
    
    enum Mode {
        case None
        case Coffee
        case Gym
        case Food
    }
    
    var mode = Mode.None
    
    func animateButton(button: UIButton, filledImage: String) {
        
        let filledImage = UIImage(named: filledImage)
        button.transform = CGAffineTransformMakeScale(0.5, 0.5)
    
        UIView.animateWithDuration(0.5, delay: 0,usingSpringWithDamping: 0.2,
            initialSpringVelocity: 6.0,
            options: UIViewAnimationOptions.AllowUserInteraction,
            animations: {
                button.setImage(filledImage, forState: .Normal)
                button.transform = CGAffineTransformIdentity
            }, completion: nil)
    
    }
    
    func setDefaultImage
        (button1: UIButton?, image1: String?,
         button2: UIButton?, image2: String?){
        
        let image1 = UIImage(named: image1!)
        let image2 = UIImage(named: image2!)

        button1?.setImage(image1, forState: .Normal)
        button2?.setImage(image2, forState: .Normal)
    }
    
    var data = DataManager.sharedInstance
    @IBAction func buttonPressed(sender: AnyObject) {
        
        if sender.tag == 1 && self.mode != .Coffee {
            removeMapPins()
            
            self.data.removeSpecificListItems(self.data.coffeeList)
            
            for business in self.data.coffeeList {
                self.createMapPin("gyms", business: business)
            }
            
            //sets the selected button to the highlighted image with a spring animation
            animateButton(self.coffeeButton, filledImage: "coffeeButton.png")
            //sets the other two buttons to their default image
            setDefaultImage(gymsButton, image1: "gymsUnfilledGrey.png", button2: foodButton, image2: "foodUnfilledGrey.png")
            mode = .Coffee
        }
        
        if sender.tag == 2 && self.mode != .Gym{
            
            //clean all the data
            removeMapPins()
            self.data.removeSpecificListItems(self.data.gymsList)
            
            for business in self.data.gymsList {
                self.createMapPin("gyms", business: business)
            }
            
            animateButton(self.gymsButton, filledImage: "gymsButton.png")
            setDefaultImage(coffeeButton, image1: "coffeeUnfilledGrey.png", button2: foodButton, image2: "foodUnfilledGrey.png")
            mode = .Gym
        }
        
        if sender.tag == 3 && self.mode != .Food{
            removeMapPins()
            
            self.data.removeSpecificListItems(self.data.foodList)
            
            for business in self.data.foodList {
                self.createMapPin("food", business: business)
            }
            
            animateButton(self.foodButton, filledImage: "foodButton.png")
            setDefaultImage(coffeeButton, image1: "coffeeUnfilledGrey.png", button2: gymsButton, image2: "gymsUnfilledGrey.png")
            mode = .Food
        }
    }
    
    func removeMapPins() {
        for annotation in map.annotations {
            self.map.removeAnnotation(annotation)
        }
    }
    
    @IBAction func centerMap(sender: AnyObject) {
        if let location = self.currentLocation {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.map.setRegion(region, animated: true)
        }
    }
    
    
    func createMapPin(query: String, business: Business)  {
        
        var annotationView:MKPinAnnotationView!
        var pointAnnotation:CustomPointAnnotation! = CustomPointAnnotation()
        
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: business.latitude!, longitude: business.longitude!)
            pointAnnotation.title = "\(business.name!)"
            pointAnnotation.subtitle = business.address!
        
        //Special pin images.
        func setImage(name: String) {
            pointAnnotation.pinCustomImageName = "starbucks"
        }
        
        if business.name! == "Starbucks" {
            setImage("starbucks")
        }
        else if business.name! == "Dunkin' Donuts" {
            setImage("dunkin")
        }
        else if business.name!.rangeOfString("Chipotle") != nil {
            setImage("chipotle")
        }
        else if business.name!.rangeOfString("CrossFit") != nil {
            setImage("crossfit")
        }
        else if business.name!.rangeOfString("YMCA") != nil {
            setImage("ymca")
        }
        else if business.name!.rangeOfString("24") != nil {
            setImage("24hour")
        }
            //special asian food map pin
        else if business.categories!.rangeOfString("Sushi") != nil ||
        business.categories!.rangeOfString("Korean") != nil ||
        business.categories!.rangeOfString("Chinese") != nil ||
        business.categories!.rangeOfString("Thai") != nil ||
        business.categories!.rangeOfString("Japanese") != nil ||
        business.categories!.rangeOfString("Taiwanese") != nil ||
        business.categories!.rangeOfString("Ramen") != nil ||
        business.categories!.rangeOfString("Asian") != nil
        {
            setImage("asian")
        }
        else {
            setImage(query)
        }
        
        annotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        self.map.addAnnotation(annotationView.annotation!)
        
        }
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat)
    {
        if distance <= 364.0
        {
            buttonsBottomConstraint.constant = distance + buttonsBottomDistance
        }
        else
        {
            buttonsBottomConstraint.constant = 364.0 + buttonsBottomDistance
        }
    }
    
    //MARK: Mapview delegate methods
    
    //animates the appeareance of map pins
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        let av: MKAnnotationView
        
        var delayInterval: NSTimeInterval = 0
        
        //grow  in animation like starbucks!
        for av in views {
            
            //completely invisible
            let shrunkenState = CGAffineTransformScale(CGAffineTransformIdentity, 0.0, 0.0)
            av.transform = shrunkenState
            av.alpha = 0.25
            
            UIView.animateWithDuration(0.45, delay: delayInterval, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                
                //transforms it to original size
                let expandedState = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
                av.transform = expandedState
                av.alpha = 1
                
                UIView.commitAnimations()
                }, completion: nil)
            
            delayInterval += 0.0625
        }
    }
    

    //creates the elements of the custom pin!
    func mapView(mapView: MKMapView,
                 viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView?{
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseIdentifier = "pin"
        
        var av = self.map.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier)
        if av == nil {
            av = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            av!.canShowCallout = true
        }
        else {
            av!.annotation = annotation
        }
        
        let customPointAnnotation = annotation as! CustomPointAnnotation
        av!.image = UIImage(named:customPointAnnotation.pinCustomImageName)
        
        //left callout for navigation.
        let image = UIImage(named: "car.png")
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 40, 40)
        button.setImage(image, forState: .Normal)
        av?.leftCalloutAccessoryView = button
        
        return av
    }
    
    //brings navigation to maps
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = view.annotation!.title!
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMapsWithLaunchOptions(launchOptions)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}




