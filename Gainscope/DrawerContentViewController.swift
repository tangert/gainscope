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

class DrawerContentViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gripperView: UIView!
    @IBOutlet weak var seperatorHeightConstraint: NSLayoutConstraint!
    var selectedIndexPath: NSIndexPath? = nil
    
    private var data = DataManager.sharedInstance.listItems
    private var searchData = [Business]()
    private var tap: UITapGestureRecognizer!

    
    var locationData = PrimaryContentViewController.sharedInstance.locationManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DrawerContentViewController.updateTableViewData(_:)) , name: "updateTableViewData", object: nil)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        searchBar.delegate = self
        
        gripperView.layer.cornerRadius = 2.5
        seperatorHeightConstraint.constant = 1.0 / UIScreen.mainScreen().scale
        tableView.separatorStyle = .None
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
    }
    
    func updateTableViewData(notification: NSNotification) {
        UIView.transitionWithView(self.tableView, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            
            self.data = notification.object as! [Business]
            self.searchData = self.data
            self.tableView.reloadData()
            
        }, completion: nil)
    }
    
}

extension DrawerContentViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchData.count != 0 {
            return searchData.count
        } else {
            return data.count
        }
    }
    
    
    //expanding tableview
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch selectedIndexPath {
        case nil:
            selectedIndexPath = indexPath
        default:
            if selectedIndexPath! == indexPath {
                selectedIndexPath = nil
            } else {
                selectedIndexPath = indexPath
            }
        }
        
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    //expanding tableview
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let index = indexPath
        
        if selectedIndexPath != nil {
            if index == selectedIndexPath {
                return 170
            } else {
                return 100
            }
        } else {
            return 100
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        tableView.separatorStyle = .None
        let cell:CustomCell? = tableView.dequeueReusableCellWithIdentifier("cell") as! CustomCell?
        
        cell?.updateUI()
        
        if searchBar.text != "" &&  self.searchData.count != 0 {
            cell?.bindData(self.searchData[indexPath.row])
        }  else {
            cell?.bindData(self.data[indexPath.row])
        }
        return cell!
    }
    
}

extension DrawerContentViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
 
    func imageForEmptyDataSet(scrollView: UIScrollView) -> UIImage? {
        return UIImage(named: "noData.png")
    }
    
}

extension DrawerContentViewController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight() -> CGFloat {
        return 57.0
    }
    
    func partialRevealDrawerHeight() -> CGFloat {
        return 364.0
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController) {
        tableView.scrollEnabled = drawer.drawerPosition == .Open
        
        if drawer.drawerPosition != .Open {
            searchBar.resignFirstResponder()
        }
    }
    
}

extension DrawerContentViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        let placemark = MKPlacemark(coordinate: view.annotation!.coordinate, addressDictionary: nil)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = view.annotation!.title!
        
        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
        mapItem.openInMapsWithLaunchOptions(launchOptions)
    }
}

extension DrawerContentViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        view.addGestureRecognizer(tap)
        if let drawerVC = self.parentViewController as? PulleyViewController {
            drawerVC.setDrawerPosition(.Open, animated: true)
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        view.removeGestureRecognizer(tap)
    }
    
    func handleTap() {
        view.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchData = data
        } else {
            searchData = searchData.filter {
                return $0.name!.containsString(searchText)
            }
        }
        tableView.reloadData()
    }
    
}