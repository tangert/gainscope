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

class DrawerContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PulleyDrawerViewControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var gripperView: UIView!
    @IBOutlet weak var seperatorHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Tableview loaded")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DrawerContentViewController.updateTableViewData(_:)) , name: "updateTableViewData", object: nil)
        
        gripperView.layer.cornerRadius = 2.5
        seperatorHeightConstraint.constant = 1.0 / UIScreen.mainScreen().scale
        
        tableView.delegate = self
        tableView.dataSource = self
        
        print("List item count: \(DataManager.sharedInstance.listItems.count)")
        
    }

    
    func updateTableViewData(notification: NSNotification) {
       
        self.tableView.reloadData()
        print("Notfication from PrimaryView sent. ListItem Count: \(DataManager.sharedInstance.listItems.count)")
    }
        
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 81.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return DataManager.sharedInstance.listItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("Cell configuration is called.")

        var cell:CustomCell? = tableView.dequeueReusableCellWithIdentifier("cell") as! CustomCell?
        
        cell?.location.text = DataManager.sharedInstance.listItems[indexPath.row].name!
        cell?.address.text = DataManager.sharedInstance.listItems[indexPath.row].address!
       
        if let url = NSURL(string: (DataManager.sharedInstance.listItems[indexPath.row].imageURL?.absoluteString)!),
            data = NSData(contentsOfURL: url)
        {
            cell?.companyImage.image = UIImage(data: data)
            
        } else {
            
            cell?.companyImage.image = nil
            
        }
        
        cell?.companyImage.layer.cornerRadius = 10
        cell?.companyImage.layer.masksToBounds = true
        
        return cell!
    }
    
    // MARK: Drawer Content View Controller Delegate
    
    func collapsedDrawerHeight() -> CGFloat
    {
        return 58.0
    }
    
    func partialRevealDrawerHeight() -> CGFloat
    {
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
    
    // MARK: Search Bar delegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        if let drawerVC = self.parentViewController as? PulleyViewController
        {
            drawerVC.setDrawerPosition(.Open, animated: true)
        }
    }
    
}
