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
import EasyTransition
import Async

class PrimaryContentViewController: UIViewController {
        
    //Yelp Client info
    var yelpClient: YelpClient!
    let yelpConsumerKey = "uDLkplNRgQcI9sM0CMnHxg"
    let yelpConsumerSecret = "2-34WuoVmOzCEs8NNWrdW0oAECc"
    let yelpToken = "yULdo-JwtBGgi1uNRvW-Yprll86x2JlU"
    let yelpTokenSecret = "wvgz30HjKdqR9Ul0qKSyDd4ASCM"
    
    var transition: EasyTransition?
    var setImageWithAnimate: (UIImage->Void)!
    static var sharedInstance = PrimaryContentViewController()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.yelpClient = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        //Initial button setup
        self.buttonBackground.layer.cornerRadius = 20
        self.buttonBackground.clipsToBounds = true
        
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
        self.map.showsCompass = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PrimaryContentViewController.centerMap(_:)), name: "centerMap", object: nil)
        
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
    
    @IBOutlet weak var buttonsBottomConstraint: NSLayoutConstraint!
    private let buttonsBottomDistance: CGFloat = 0.0
    
    func removeMapPins() {
        for annotation in map.annotations {
            self.map.removeAnnotation(annotation)
        }
    }
    
    func centerMap(sender: AnyObject) {
        
        if let location = self.locationManager.location {
            
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            self.map.setRegion(region, animated: true)
        
        } else {
            
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
    
    enum Mode {
        case None
        case Coffee
        case Gym
        case Food
    }
    
    var mode = Mode.None
    var pressedAlready = false
    var gsColor = UIColor(red: 249/255, green: 134/255, blue: 110/255, alpha: 1.0)
    
    @IBAction func buttonPressed(button: UIButton) {
        
        if Reachability.isConnectedToNetwork() == true && locationFound == true {
        
            let progress = NVActivityIndicatorView(
            frame: button.bounds,
            type: .BallScale,
            color: gsColor)
            
            if pressedAlready == false {
                
                if button.tag == 1 && self.mode != .Coffee {
                    
                    print("Coffee button Pressed")
                    
                    pressedAlready = true
                    initialButtonSetup(button, progress: progress)
                    createContent("coffee", button: button, progress: progress)
                    setDefaultImage(gymsButton, image1: "gymUnfilledGrey.png", button2: foodButton, image2: "foodUnfilledGrey.png")
                    mode = .Coffee
                    
                }
                
                if button.tag == 2 && self.mode != .Gym{
                    print("Gym button Pressed")
                    
                    pressedAlready = true
                    initialButtonSetup(button, progress: progress)
                    createContent("gym", button: button, progress: progress)
                    setDefaultImage(coffeeButton, image1: "coffeeUnfilledGrey.png", button2: foodButton, image2: "foodUnfilledGrey.png")
                    mode = .Gym
                }
                
                if button.tag == 3 && self.mode != .Food{
                    print("Food button Pressed")
                    
                    pressedAlready = true
                    initialButtonSetup(button, progress: progress)
                    createContent("food", button: button, progress: progress)
                    setDefaultImage(coffeeButton, image1: "coffeeUnfilledGrey.png", button2: gymsButton, image2: "gymUnfilledGrey.png")
                    mode = .Food
                }
                
            }
            
            else {
                errorPressAnimation(button)
            }
            
        }
            
            else {
                
                let alert = UIAlertController(title: "No connection!", message: "Try finding your gains later.", preferredStyle: UIAlertControllerStyle.Alert)
                
                let alertAction = UIAlertAction(title: "Fine", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
                alert.addAction(alertAction)
                self.presentViewController(alert, animated: true) { () -> Void in }
                
            }
        }
    
    
    func initialButtonSetup(button: UIButton, progress: NVActivityIndicatorView) {
        button.addSubview(progress)
        initialPressAnimation(button)
        progress.startAnimation()
        removeMapPins()
        DataManager.sharedInstance.removeItems()
    }
    
    func initialPressAnimation(button: UIButton) {
        let pressedState = CGAffineTransformMakeScale(0.8, 0.8)
        UIView.animateWithDuration(0.125, animations: {
            button.transform = pressedState
            }, completion: nil)
        
    }
    
    func errorPressAnimation(button: UIButton) {
        
        let pressedState = CGAffineTransformMakeScale(0.8, 0.8)

        UIView.animateWithDuration(0.125, animations: {
            button.transform = pressedState
        }, completion: nil)
        
        button.transform = CGAffineTransformIdentity
        
        let anim=CABasicAnimation(keyPath: "transform.rotation")
        anim.toValue=NSNumber(double: -M_PI/16)
        anim.fromValue=NSNumber(double: M_PI/16)
        anim.duration=0.1
        anim.repeatCount=1.5
        anim.autoreverses=true
        button.layer.addAnimation(anim, forKey: "iconShake")
        
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
        
            self.yelpClient.searchWithTerm(term, completion: { (results: [Business]!, error: NSError!) -> Void in
         
                for business in results {
                    self.createMapPin(term, business: business)
                    DataManager.sharedInstance.addItem(business)
                }
         
                self.animateButton(button, filledImage: "\(term)Button.png")
                self.pressedAlready = false
                progress.stopAnimation()
                progress.hidesWhenStopped = true
         })
        
    }
    
    func createMapPin(query: String, business: Business)  {
        
        let coord = CLLocationCoordinate2DMake(business.latitude!, business.longitude!)
        let annotation = CustomAnnotation(title: business.name!, subtitle: business.distance!, coordinate: coord, imageName: query, business: business)
        
        print(annotation.business?.name)
        
        //Special pin images.
        
        if business.name! == "Starbucks" {
            annotation.imageName = "starbucks"
        }
            
        else if business.name! == "Dunkin' Donuts" {
            annotation.imageName = "dunkin"
        }
            
        else if business.name!.rangeOfString("Chipotle") != nil {
            annotation.imageName = "chipotle"
        }
            
        else if business.name!.rangeOfString("CrossFit") != nil
            || business.name!.rangeOfString("Crossfit") != nil {
            annotation.imageName = "crossfit"
            
        } else if business.name!.rangeOfString("YMCA") != nil {
            annotation.imageName = "ymca"
            
        }
            
        else if business.name!.rangeOfString("24") != nil {
            annotation.imageName = "24hour"
            
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
            annotation.imageName = "asian"
        }
            
        else {
            annotation.imageName = query
        }
        
        self.map.addAnnotation(annotation)
        
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
        if let location = locations.last {
           
            self.locationFound = true
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07))
            
            self.map.setRegion(region, animated: true)
            self.locationManager.stopUpdatingLocation()
            
        }
        
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
            
            delayInterval += 0.0234375
        }
    }
    
    
    //creates the elements of the custom pin!
    func mapView(mapView: MKMapView,
                 viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
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
        
        let customAnnotation = annotation as! CustomAnnotation
        
        av!.image = UIImage(named:customAnnotation.imageName!)
        
        //left callout for navigation.
        let navImage = UIImage(named: "car.png")
        let navButton = UIButton(type: .Custom)
        navButton.frame = CGRectMake(0, 0, 40, 40)
        navButton.setImage(navImage, forState: .Normal)
        
        let infoButton = UIButton(type: UIButtonType.InfoLight)
        infoButton.tintColor = self.gsColor
        
        av?.leftCalloutAccessoryView = infoButton
        av?.rightCalloutAccessoryView = navButton
        
        // HELP PLS
        av?.business = customAnnotation.business
        //
        
        infoButton.tag = 1
        navButton.tag = 2
        
        return av
    }
    

    func showDetailView(sender: AnyObject) {
        let detailVC = storyboard!.instantiateViewControllerWithIdentifier("DetailViewController")
        transition = EasyTransition(attachedViewController: detailVC)
        transition?.transitionDuration = 0.3
        transition?.direction = .Bottom
        
        let leftRightMargins = ((self.parentViewController?.view.frame.width)!/(10*1.5))
        let topBottomMargins = ((self.parentViewController?.view.frame.height)!/(10*0.5))

        transition?.margins = UIEdgeInsets(top: topBottomMargins, left: leftRightMargins, bottom: topBottomMargins, right: leftRightMargins)

        transition?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
        
        detailVC.view.layer.cornerRadius = 20
        presentViewController(detailVC, animated: true, completion: nil)
    }
    
    //brings navigation to maps
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control.tag == 1 {
            
            //print("Selected directly from control. \(view.business!.name!)")
            
            //send notification sending business data froms pecific annotation
        NSNotificationCenter.defaultCenter().postNotificationName("updateBusinessData", object: view.business)
            self.showDetailView(control)

        }
        
        if control.tag == 2 {
            
            let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
            
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = view.annotation!.title!
            
            let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMapsWithLaunchOptions(launchOptions)
            
        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



