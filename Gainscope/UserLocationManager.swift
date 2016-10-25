//
//  UserLocation.swift
//  Gainscope
//
//  Created by Tyler Angert on 8/2/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import Foundation
import MapKit
import NotificationCenter
import AFNetworking
import Async


protocol LocationUpdateProtocol {
    func locationDidUpdateToLocation(location : CLLocation)
}

/// Notification on update of location. UserInfo contains CLLocation for key "location"
let kLocationDidChangeNotification = "LocationDidChangeNotification"

class UserLocationManager: NSObject, CLLocationManagerDelegate {
    
    static let sharedManager = UserLocationManager()
    private var locationManager = CLLocationManager()

    var currentLocation : CLLocation?
    var delegate : LocationUpdateProtocol!
    
    private override init () {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    //tracking distance traveled
    var startLocation:CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance:Double = 0
    var data = DataManager.sharedInstance

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //getting the current
        if let location = locations.last {
            
            //centering the map
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07))
            PrimaryContentViewController.sharedInstance.map.setRegion(region, animated: true)
            self.locationManager.stopUpdatingLocation()
            
            //preloading all the data into data manager to avoid excess and duplicate API calls.
            //reloads every 0.25 miles of traveled distance.
            Async.utility {
                
                if self.startLocation == nil {
                    self.startLocation = locations.first

                } else {
                    if let lastLocation = locations.last {
                        let distance = self.startLocation.distanceFromLocation(lastLocation)
                        let lastDistance = lastLocation.distanceFromLocation(lastLocation)
                        self.traveledDistance += lastDistance
                        
                        //if distance greater than 400m, reset travelled distance and perform searches again
                        if self.traveledDistance >= 400 {
                            //perform searches
                            self.traveledDistance = 0
                            
                            //gotta use notifications somewhere in here
                            //receive notifications from DataManager, have an update function
//                            self.data.performSearches()
//                            self.data.addAllLists(self.data.coffeeList, self.data.foodList, self.data.gymsList)
                            
                        }
                    }
                }
                self.lastLocation = locations.last
            }
        }
        
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        currentLocation = newLocation
        let userInfo : NSDictionary = ["location" : currentLocation!]
        
        Async.main {
            self.delegate.locationDidUpdateToLocation(self.currentLocation!)
            NSNotificationCenter.defaultCenter().postNotificationName(kLocationDidChangeNotification, object: self, userInfo: userInfo as [NSObject : AnyObject])
        }
    }
    
    
    var locationFound = true
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
        
        let alert = UIAlertController(title: "Oh crap!", message: "We couldn't find your current location.", preferredStyle: UIAlertControllerStyle.Alert)
        
        self.locationFound = false
        
        //put this in primary view controller
        let alertAction = UIAlertAction(title: "lol aight", style: UIAlertActionStyle.Default) {
            (UIAlertAction) -> Void in
        }
        
        alert.addAction(alertAction)
        PrimaryContentViewController.sharedInstance.presentViewController(alert, animated: true)
        
        {
            () -> Void in
        }
        
    }

    
    
    
}