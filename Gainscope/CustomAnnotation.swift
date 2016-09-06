//
//  CustomMKAnnotation.swift
//  Gainscope
//
//  Created by Tyler Angert on 9/6/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var imageName: String?
    var business: Business?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, imageName: String, business: Business? = nil) {
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.business = business
    }
    
    
}