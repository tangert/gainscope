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
import NotificationCenter


class PrimaryContentViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, PulleyPrimaryContentControllerDelegate {

    var client: YelpClient!
    let yelpConsumerKey = "uDLkplNRgQcI9sM0CMnHxg"
    let yelpConsumerSecret = "2-34WuoVmOzCEs8NNWrdW0oAECc"
    let yelpToken = "yULdo-JwtBGgi1uNRvW-Yprll86x2JlU"
    let yelpTokenSecret = "wvgz30HjKdqR9Ul0qKSyDd4ASCM"
    
    let locationManager = CLLocationManager()
    
    static let sharedInstance = PrimaryContentViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.client = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateNotificationSentLabel", name: mySpecialNotificationKey, object: nil)
        
        //button setup
        roundButton(coffeeButton, radius: 10)
        roundButton(gymsButton, radius: 10)
        roundButton(gainsButton, radius: 10)
        roundButton(centerButton, radius: 10)
        
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //getting the current location and centering the map
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        
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
                print( "\(startLocation)")
                print( "\(lastLocation)")
                print("FULL DISTANCE: \(traveledDistance)")
                print("STRAIGHT DISTANCE: \(distance)")
            }
        }
        lastLocation = locations.last
        
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
        
        let alert = UIAlertController(title: "Oh crap!", message: "We couldn't find your current location.", preferredStyle: UIAlertControllerStyle.Alert)
        let alertAction = UIAlertAction(title: "lol aight", style: UIAlertActionStyle.Default) {
            (UIAlertAction) -> Void in
        }
        alert.addAction(alertAction)
        self.presentViewController(alert, animated: true)
        {
            () -> Void in
        }
        
    }
    
    //initial button and map setup
    @IBOutlet weak var coffeeButton: UIButton!
    @IBOutlet weak var gymsButton: UIButton!
    @IBOutlet weak var gainsButton: UIButton!
    @IBOutlet weak var centerButton: UIButton!
    @IBOutlet weak var map: MKMapView!

    @IBOutlet weak var buttonsBottomConstraint: NSLayoutConstraint!
    private let buttonsBottomDistance: CGFloat = 8.0

    func roundButton(button: UIButton, radius: CGFloat) -> UIButton {
        button.layer.cornerRadius = radius
        return button
    }
    
    func drawerChangedDistanceFromBottom(drawer: PulleyViewController, distance: CGFloat)
    {
        if distance <= 368.0
        {
            buttonsBottomConstraint.constant = distance + buttonsBottomDistance
        }
        else
        {
            buttonsBottomConstraint.constant = 368.0 + buttonsBottomDistance
        }
    }
    
    @IBAction func centerMap(sender: AnyObject) {
        
        let location = self.locationManager.location
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
        self.map.setRegion(region, animated: true)
        
    }
    
    enum Mode {
        case None
        case Gym
        case Coffee
        case Gains
    }
    
    var mode = Mode.None
    
    @IBAction func buttonPressed(sender: AnyObject) {
        
        NSNotificationCenter.defaultCenter().postNotificationName("loadTableViewData", object: self.listItems)
        
        if sender.tag == 1 && self.mode != .Coffee {
            
            if listItems.count != 0 {
                listItems.removeAll()
            }
            
            removeMapPins()
            createContent("coffee")
            mode = .Coffee
        }
        
        if sender.tag == 2 && self.mode != .Gym{

            if listItems.count != 0 {
                listItems.removeAll()
            }
            
            removeMapPins()
            createContent("gyms")
            mode = .Gym
        }
        
        if sender.tag == 3 && self.mode != .Gains{

            if listItems.count != 0 {
                listItems.removeAll()
            }
            
            removeMapPins()
            createContent("food")
            mode = .Gains
        }
    }
    
    func removeMapPins() {
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
    }
    
    var listItems: [Business] = [Business]()
    
    func createContent(term: String) {
        
        if Reachability.isConnectedToNetwork() == true {
            
            print("Internet is ok.")
            
            self.client.searchWithTerm(term, completion: { (businesses: [Business]!, error: NSError!) -> Void in
                
                for business in businesses {
                    self.createMapPin(term, business: business)
                    self.listItems.append(business)
                }
            })
            
        } else {
            
            let alert = UIAlertController(title: "No internet!", message: "Try finding your gains when you are connected.", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction = UIAlertAction(title: "Fine", style: UIAlertActionStyle.Default) {
                (UIAlertAction) -> Void in
            }
            alert.addAction(alertAction)
            self.presentViewController(alert, animated: true)
            {
                () -> Void in
            }
            
        }
        
    }
    
    enum pinCase {
        //special coffees
        case starbucks
        case dunkin
        
        //special gyms
        case crossfit
        case anytime
        case ymca
        
        //special foods
        case chipotle
        case sushi
        
        //default
        case query
    }
    
    func createMapPin(query: String, business: Business)  {
        
        print("createMapPins called.")
        
        var annotationView:MKPinAnnotationView!
        var pointAnnotation:CustomPointAnnotation!
            
            print("Location: \(business.name!)")
            print("Address: \(business.address!)")
            print("Coordinate: \(business.coordinate)")
            print("Distance from me: \(business.distance!)")
            print("Image URL: \(business.imageURL)")
            print("Review count: \(business.reviewCount!)")
            print("Average rating: \(business.rating!)")
            print("\n")
            
            pointAnnotation = CustomPointAnnotation()
        
            pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: business.latitude!, longitude: business.longitude!)
            pointAnnotation.title = "\(business.name!)"
            pointAnnotation.subtitle = business.address!
        
        
            //custom pin images, depending on enum case
     
            pointAnnotation.pinCustomImageName = query
            
            annotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: "pin")
        
            self.map.addAnnotation(annotationView.annotation!)
            
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
        
        print("delegate called")

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
        let image = UIImage(named: "navigation-5.png")
        let button = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 30, 30)
        button.setImage(image, forState: .Normal)
        av?.leftCalloutAccessoryView = button
        
        return av
    }
    
    //brings navigation to maps
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
        
        // The map item is the restaurant location
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




