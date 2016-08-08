//
//  UserLocationManager.swift
//  Gainscope
//
//  Created by Tyler Angert on 8/7/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import Foundation
import CoreLocation

protocol UserLocationManagerDelegate {
    func tracingLocation(currentLocation: CLLocation)
    func tracingLocationDidFailWithError(error: NSError)
}

class UserLocationManager: NSObject, CLLocationManagerDelegate {
    
    class var sharedInstance: UserLocationManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            
            static var instance: UserLocationManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = UserLocationManager()
        }
        return Static.instance!
    }
    
    var locationManager: CLLocationManager?
    
    //tracking distance traveled
    var startLocation:CLLocation!
    var traveledDistance:Double = 0
    var lastLocation: CLLocation?
    var delegate: UserLocationManagerDelegate?
    
    override init() {
        super.init()
        
        self.locationManager = CLLocationManager()
        guard let locationManager = self.locationManager else {
            return
        }
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            // you have 2 choice
            // 1. requestAlwaysAuthorization
            // 2. requestWhenInUseAuthorization
            locationManager.requestWhenInUseAuthorization()
        }
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the location data
        locationManager.distanceFilter = 200 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        locationManager.delegate = self
    }
    
    func startUpdatingLocation() {
        print("Starting Location Updates")
        self.locationManager?.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        print("Stop Location Updates")
        self.locationManager?.stopUpdatingLocation()
    }
    
    
    var location: CLLocation!
    // CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard self.location == locations.last else {
            return
        }
        
        // singleton for get last location
        self.lastLocation = location
        
        // use for real time update location
        updateLocation(location)
        
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
        
        // do on error
        updateLocationDidFailWithError(error)
    }
    
    // Private function
    private func updateLocation(currentLocation: CLLocation){
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocation(currentLocation)
    }
    
    private func updateLocationDidFailWithError(error: NSError) {
        
        guard let delegate = self.delegate else {
            return
        }
        
        delegate.tracingLocationDidFailWithError(error)
    }
}
