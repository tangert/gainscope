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
    var searchTerm: String?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, imageName: String, searchTerm: String, business: Business? = nil) {
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.business = business
        self.searchTerm = searchTerm
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
        static var searchTerm: String?
    }
    
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
    
    var searchTerm:String? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.searchTerm) as? String)!
            
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.searchTerm, newValue as String!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    override public func didAddSubview(subview: UIView) {
        if selected {
            setNeedsLayout()
        }
    }
    
    override public func layoutSubviews() {
        
        // MKAnnotationViews only have subviews if they've been selected.
        // short-circuit if there's nothing to loop over
        
        if !selected {
            return
        }
        
        loopViewHierarchy({(view : UIView) -> Bool in
            if let label = view as? UILabel {
                label.font = UIFont(name: "Bariol", size: 15)
                return false
            }
            return true
        })
    }
}

typealias ViewBlock = (view : UIView) -> Bool

extension UIView {
    func loopViewHierarchy(block : ViewBlock?) {
        
        if block?(view: self) ?? true {
            for subview in subviews {
                subview.loopViewHierarchy(block)
            }
        }
    }
}

