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
import ObjectiveC

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

private struct AssociatedKeys {
    static var business:Business!
}

extension MKAnnotation {
    
    var business:Business? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.business) as? Business)!
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.business, newValue as Business!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

extension MKAnnotationView {
    private struct AssociatedKeys {
        static var business:Business?
    }
    
    var business:Business? {
        get {
            //this works
            return (objc_getAssociatedObject(self, &AssociatedKeys.business) as? Business)!
            
        }
        set {
            if let newValue = newValue {
                //print("got object")
                objc_setAssociatedObject(self, &AssociatedKeys.business, newValue as Business!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            } else {
            print("did not get object")
            }
        }
    }
}
