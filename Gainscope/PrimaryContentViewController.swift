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
import NVActivityIndicatorView
import AddressBookUI
import NotificationCenter
import AFNetworking

class PrimaryContentViewController: UIViewController {
        
    //Yelp Client info
    var yelpClient: YelpClient!
    let yelpConsumerKey = "uDLkplNRgQcI9sM0CMnHxg"
    let yelpConsumerSecret = "2-34WuoVmOzCEs8NNWrdW0oAECc"
    let yelpToken = "yULdo-JwtBGgi1uNRvW-Yprll86x2JlU"
    let yelpTokenSecret = "wvgz30HjKdqR9Ul0qKSyDd4ASCM"
    
    static var sharedInstance = PrimaryContentViewController()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.yelpClient = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        //Initial button setup
        self.buttonBackground.layer.cornerRadius = 20
        self.buttonBackground.clipsToBounds = true
        self.centerButtonBackground.layer.cornerRadius = 20
        self.centerButtonBackground.clipsToBounds = true
        
        let coffeeImage : UIImage = UIImage(named: "coffeeUnfilledGrey.png")!
        let gymImage: UIImage = UIImage(named: "gymUnfilledGrey.png")!
        let foodImage: UIImage = UIImage(named: "foodUnfilledGrey.png")!
        self.coffeeButton.setImage(coffeeImage, forState: .Normal)
        self.gymsButton.setImage(gymImage, forState: .Normal)
        self.foodButton.setImage(foodImage, forState: .Normal)
        
        
        //map setup
        self.map.delegate = self
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        self.map.showsUserLocation = true
        
    }

    var startLocation:CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance:Double = 0
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
    
    func removeMapPins() {
        for annotation in map.annotations {
            self.map.removeAnnotation(annotation)
        }
    }
    
    @IBAction func centerMap(sender: AnyObject) {
        
        if let location = self.locationManager.location {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.map.setRegion(region, animated: true)
        }
        
        
    }
    
    
    enum Mode {
        case None
        case Coffee
        case Gym
        case Food
    }
    
    var mode = Mode.None
    
    @IBAction func buttonPressed(button: UIButton) {
        
        var progress = NVActivityIndicatorView(
            frame: button.bounds,
            type: .BallScale,
            color: UIColor(red: 249/255, green: 134/255, blue: 110/255, alpha: 1.0))
        
        if button.tag == 1 && self.mode != .Coffee {
            print("Coffee button Pressed")
            
            //loading animations
            button.addSubview(progress)
            initialPressAnimation(button)
            progress.startAnimation()
            
            //previous data removal
            removeMapPins()
            DataManager.sharedInstance.removeItems()
            
            //does Yelp search, populates map with Pins, and animates selected button.
            createContent("coffee", button: button, progress: progress)
            
            //sets the other two buttons to their default image
            setDefaultImage(gymsButton, image1: "gymUnfilledGrey.png", button2: foodButton, image2: "foodUnfilledGrey.png")
            
            
            mode = .Coffee
            
        }
        
        if button.tag == 2 && self.mode != .Gym{
            print("Gym button Pressed")
            
            button.addSubview(progress)
            initialPressAnimation(button)
            progress.startAnimation()
            removeMapPins()
            DataManager.sharedInstance.removeItems()
            
            createContent("gym", button: button, progress: progress)
            setDefaultImage(coffeeButton, image1: "coffeeUnfilledGrey.png", button2: foodButton, image2: "foodUnfilledGrey.png")
            mode = .Gym
        }
        
        if button.tag == 3 && self.mode != .Food{
            print("Food button Pressed")
            
            button.addSubview(progress)
            initialPressAnimation(button)
            progress.startAnimation()
            removeMapPins()
            DataManager.sharedInstance.removeItems()
            
            createContent("food", button: button, progress: progress)
            setDefaultImage(coffeeButton, image1: "coffeeUnfilledGrey.png", button2: gymsButton, image2: "gymUnfilledGrey.png")
            mode = .Food
        }
    }
    
    func initialPressAnimation(button: UIButton) {
        let pressedState = CGAffineTransformMakeScale(0.8, 0.8)
        UIView.animateWithDuration(0.125, animations: {
            button.transform = pressedState
            }, completion: nil)
        
    }
    
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
    
    
    func createContent(term: String, button: UIButton, progress: NVActivityIndicatorView) {
        
         if Reachability.isConnectedToNetwork() == true {
         
            print("Internet is ok.")
         
            self.yelpClient.searchWithTerm(term, completion: { (results: [Business]!, error: NSError!) -> Void in
         
                for business in results {
                    self.createMapPin(term, business: business)
                    DataManager.sharedInstance.addItem(business)
                }
         
                func setImage(image: String) {
                    self.animateButton(button, filledImage: image)
                }
         
                if button.tag == 1 {
                    setImage("\(term)Button.png")
                } else if button.tag == 2 {
                    setImage("\(term)Button.png")
                } else if button.tag == 3 {
                    setImage("\(term)Button.png")
                }
         
                progress.stopAnimation()
                progress.hidesWhenStopped = true
         })
         
         } else {
         
         let alert = UIAlertController(title: "No internet!", message: "Try finding your gains when you are connected.", preferredStyle: UIAlertControllerStyle.Alert)
         
            let alertAction = UIAlertAction(title: "Fine", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true) { () -> Void in }
         
         }
        
    }
    
    func createMapPin(query: String, business: Business)  {
        
        var annotationView:MKPinAnnotationView!
        var pointAnnotation:CustomPointAnnotation! = CustomPointAnnotation()
        
        pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: business.latitude!, longitude: business.longitude!)
        pointAnnotation.title = "\(business.name!)"
        pointAnnotation.subtitle = business.address!
        
        //Special pin images.
        
        if business.name! == "Starbucks" {
            pointAnnotation.pinCustomImageName = "starbucks"
        }
            
        else if business.name! == "Dunkin' Donuts" {
            pointAnnotation.pinCustomImageName = "dunkin"
        }
            
        else if business.name!.rangeOfString("Chipotle") != nil {
            pointAnnotation.pinCustomImageName = "chipotle"
        }
            
        else if business.name!.rangeOfString("CrossFit") != nil
            || business.name!.rangeOfString("Crossfit") != nil {
            pointAnnotation.pinCustomImageName = "crossfit"
            
        } else if business.name!.rangeOfString("YMCA") != nil {
            pointAnnotation.pinCustomImageName = "ymca"
            
        }
            
        else if business.name!.rangeOfString("24") != nil {
            pointAnnotation.pinCustomImageName = "24hour"
            
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
            pointAnnotation.pinCustomImageName = "asian"
        }
            
        else {
            pointAnnotation.pinCustomImageName = query
        }
        
        annotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        self.map.addAnnotation(annotationView.annotation!)
        
    }
    
}

//MARK: Pulley delegate methods
extension PrimaryContentViewController: PulleyPrimaryContentControllerDelegate {
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat) {
        
        if distance <= 364.0 {
            buttonsBottomConstraint.constant = distance + buttonsBottomDistance
        }
        else {
            buttonsBottomConstraint.constant = 364.0 + buttonsBottomDistance
        }
    }
    
}

//MARK: Location manager delegate methods
extension PrimaryContentViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //getting the current location and centering the map
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07))
        
        self.map.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
        //tracking distance traveled to determine duplicate API calls.
        if startLocation == nil {
            startLocation = locations.first
        } else {
            if let lastLocation = locations.last {
                let distance = startLocation.distanceFromLocation(lastLocation)
                let lastDistance = lastLocation.distanceFromLocation(lastLocation)
                traveledDistance += lastDistance
            }
        }
        lastLocation = locations.last
        
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
        
        let alert = UIAlertController(title: "Oh crap!", message: "We couldn't find your current location.", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.locationFound = false
        
        let alertAction = UIAlertAction(title: "lol aight", style: UIAlertActionStyle.Default) {
            (UIAlertAction) -> Void in
        }
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true)
        {
            () -> Void in
        }
        
    }
    
    
}

//MARK: Mapview delegate methods
extension PrimaryContentViewController: MKMapViewDelegate {
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



