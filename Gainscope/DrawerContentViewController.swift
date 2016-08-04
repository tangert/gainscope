//
//  TableViewController.swift
//  Gainscope
//
//  Created by Tyler Angert on 7/25/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import Foundation
import UIKit
import AFNetworking
import Async
import Kingfisher
import NotificationCenter
import MapKit

class DrawerContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PulleyDrawerViewControllerDelegate, UISearchBarDelegate, MKMapViewDelegate {
    
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
        
    }
    
    var cellConditional = ""
    func updateTableViewData(notification: NSNotification) {
        
        if notification.object?.name == "coffeeList" {
            self.cellConditional = "coffeeList"
        }
        else if notification.object?.name == "gymsList" {
            self.cellConditional = "gymsList"

        }
        else if notification.object?.name == "foodList" {
            self.cellConditional = "foodList"
        }
        
        UIView.transitionWithView(self.tableView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
    }
        
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func calculateHeightForConfiguredSizingCell(cell: UITableViewCell) -> CGFloat
    {
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        let height = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingExpandedSize).height + 1.0
        return height
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //20 results per query
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:CustomCell? = tableView.dequeueReusableCellWithIdentifier("cell") as! CustomCell?

        /*
        var data = DataManager.sharedInstance.coffeeList[indexPath.row]
        //set up conditionals for each list.
        if self.cellConditional == "coffeeList" {
            var data = DataManager.sharedInstance.coffeeList[indexPath.row]
        }
        else if self.cellConditional == "gymsList" {
            var data = DataManager.sharedInstance.gymsList[indexPath.row]
        }
        else if self.cellConditional == "foodList" {
            var data = DataManager.sharedInstance.foodList[indexPath.row]
        }
        
        cell?.location.text = data.name!
        cell?.reviewCount.text = "\(data.reviewCount!) reviews"
        cell?.rating.rating = data.rating as! Double
        cell?.rating.settings.updateOnTouch = false
        
        cell?.companyImage.layer.cornerRadius = 10
        cell?.companyImage.layer.masksToBounds = true
        
        //company image
        if let url = data.imageURL?.absoluteString {
            cell?.companyImage.kf_setImageWithURL(NSURL(string: url)!, placeholderImage: UIImage(named: "emptyCell.png"))
        } else {
            cell?.companyImage.image = UIImage(named: "emptyCell.png")
            
        }
        
        let category = data.categories
        //shortening the yelp categories if there is more than one
        if let range = category!.rangeOfString(",") {
            print(category!.substringToIndex(range.startIndex))
            cell?.categories.text = ("\(category!.substringToIndex(range.startIndex))  •  \(data.distance!)")
        //if there is only one cateogry
        } else {
            cell?.categories.text = ("\(data.categories!)  •  \(data.distance!)")

        }*/

        return cell!
    }
    
    // MARK: Drawer Content View Controller Delegate
    
    func collapsedDrawerHeight() -> CGFloat {
        return 58.0
    }
    
    func partialRevealDrawerHeight() -> CGFloat {
        return 364.0
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController)
    {
        tableView.scrollEnabled = drawer.drawerPosition == .Open
        
        if drawer.drawerPosition != .Open
        {
            searchBar.resignFirstResponder()
        }
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = view.annotation!.title!
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMapsWithLaunchOptions(launchOptions)
    }

    
    // MARK: Search Bar delegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        if let drawerVC = self.parentViewController as? PulleyViewController
        {
            drawerVC.setDrawerPosition(.Open, animated: true)
        }
    }
    
}
