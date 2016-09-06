//
//  Business.swift
//  Yelp
//
//  Created by Tyler Angert on 6/30/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import UIKit

class Business: NSObject {
 
    let name: String?
    let address: String?
    let URL: String?
    let imageURL: NSURL?
    let categories: String?
    let distance: String?
    let reviewCount: NSNumber?
    let rating: NSNumber?
    let phone: String?

    let coordinate: NSDictionary?
    let latitude: Double?
    let longitude: Double?
    
    init(dictionary: NSDictionary) {
        
        name = dictionary["name"] as? String
 
        let imageURLString = dictionary["image_url"] as? String
        if imageURLString != nil {
                imageURL = NSURL(string: imageURLString!)!
            } else {
                imageURL = nil
            }
 
        let location = dictionary["location"] as? NSDictionary
        var address = ""
        var coordinate = [:]
        var latitude = 0.0
        var longitude = 0.0
 
        if location != nil {
            let addressArray = location!["address"] as? NSArray
            
            if addressArray != nil && addressArray!.count > 0 {
                address = addressArray![0] as! String
            }
 
            let neighborhoods = location!["neighborhoods"] as? NSArray
                if neighborhoods != nil && neighborhoods!.count > 0 {
                    if !address.isEmpty {
                        address += ", "
                    }
                    address += neighborhoods![0] as! String
                    }
 
            let coordinates = location!["coordinate"] as? NSDictionary
                if coordinates != nil  && coordinates!.count > 0 {
                    coordinate = coordinates!
                }
 
                latitude = (coordinates!["latitude"] as? Double)!
                longitude = (coordinates!["longitude"] as? Double)!
 
        }
 
        self.address = address
        self.coordinate = coordinate
        self.latitude = latitude
        self.longitude = longitude
 
        let categoriesArray = dictionary["categories"] as? [[String]]
            if categoriesArray != nil {
                var categoryNames = [String]()
                    for category in categoriesArray! {
                        let categoryName = category[0]
                            categoryNames.append(categoryName)
                    }
 
                categories = categoryNames.joinWithSeparator(", ") }
            
            else {
                categories = nil
            }
 
        let distanceMeters = dictionary["distance"] as? NSNumber
            if distanceMeters != nil {
                let milesPerMeter = 0.000621371
                distance = String(format: "%.2f mi", milesPerMeter * distanceMeters!.doubleValue)
            } else {
                distance = nil
            }
 
        rating = dictionary["rating"] as? NSNumber
        reviewCount = dictionary["review_count"] as? NSNumber
        phone = dictionary["display_phone"] as? String
        URL = dictionary["url"] as? String
 
 }
 
    class func returnBusinesses(array array: [NSDictionary]) -> [Business] {
        var businesses = [Business]()
        for dictionary in array {
            let business = Business(dictionary: dictionary)
            businesses.append(business)
        }
        return businesses
    }
 
 
 }
