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
    
    var listItems = [Business]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Tableview loaded")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DrawerContentViewController.loadTableViewData(_:)) , name: "loadTableViewData", object: nil)
        
        gripperView.layer.cornerRadius = 2.5
        seperatorHeightConstraint.constant = 1.0 / UIScreen.mainScreen().scale
        
        tableView.delegate = self
        tableView.dataSource = self
        
        print("List item count: \(self.listItems.count)")
        
    }

    
    func loadTableViewData(notification: NSNotification) {
        
            //self.listItems = notification.object as! [Business]
        self.listItems = PrimaryContentViewController.sharedInstance.listItems
            self.tableView.reloadData()
            print(listItems.count)
    }
        
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 81.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        print("Cell configuration is called.")
        
        var cell:CustomCell? = tableView.dequeueReusableCellWithIdentifier("cell") as! CustomCell?
        
        cell?.location.text = self.listItems[indexPath.row].name
        cell?.address.text = self.listItems[indexPath.row].address
        cell?.distance.text = self.listItems[indexPath.row].distance
        
        cell?.companyImage.layer.cornerRadius = 20
        
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

    
}
