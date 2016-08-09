//
//  TableViewController.swift
//  Gainscope
//
//  Created by Tyler Angert on 7/25/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import Foundation
import UIKit
import NotificationCenter
import Kingfisher
import MapKit
import UberRides

class DrawerContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, MKMapViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, PulleyDrawerViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gripperView: UIView!
    @IBOutlet weak var seperatorHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DrawerContentViewController.updateTableViewData(_:)) , name: "updateTableViewData", object: nil)
        
        gripperView.layer.cornerRadius = 2.5
        seperatorHeightConstraint.constant = 1.0 / UIScreen.mainScreen().scale
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "noData.png")
    }
    
    func updateTableViewData(notification: NSNotification) {
        UIView.transitionWithView(self.tableView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
        //self.tableView.reloadData()
        print("Notfication from PrimaryView sent. ListItem Count: \(DataManager.sharedInstance.listItems.count)")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return DataManager.sharedInstance.listItems.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:CustomCell? = tableView.dequeueReusableCellWithIdentifier("cell") as! CustomCell?
        
        let data = DataManager.sharedInstance.listItems[indexPath.row]
        
        if data.phone != nil {
            cell?.phoneNumber = data.phone!
            
        } else {
            cell?.phoneNumber = nil
        }
        
        cell?.location.text = data.name!
        cell?.latitude = data.latitude!
        cell?.longitude = data.longitude!
        
        //caching images
        cell?.companyImage.layer.cornerRadius = 10
        cell?.companyImage.layer.masksToBounds = true
        
        if let URLString = data.imageURL?.absoluteString {
            cell?.companyImage.kf_setImageWithURL(NSURL(string: URLString)!, placeholderImage: UIImage(named: "emptyCell.png"))
            
        } else {
            cell?.companyImage.image = UIImage(named: "emptyCell.png")
        }
        
        let string = data.categories
        if let range = string!.rangeOfString(",") {
            cell?.categories.text = ("\(string!.substringToIndex(range.startIndex))  •  \(data.distance!)")
            
        } else {
            cell?.categories.text = ("\(data.categories!)  •  \(data.distance!)")
            
        }
        
        cell?.reviewCount.text = "\(data.reviewCount!) reviews"
        cell?.rating.rating = data.rating as! Double
        cell?.rating.settings.updateOnTouch = false
        
        return cell!
    }
    
    // MARK: Drawer Content View Controller Delegate
    func collapsedDrawerHeight() -> CGFloat {
        return 26.0
    }
    
    func partialRevealDrawerHeight() -> CGFloat {
        return 364.0
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController) {
        tableView.scrollEnabled = drawer.drawerPosition == .Open
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = view.annotation!.title!
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMapsWithLaunchOptions(launchOptions)
    }
    
}