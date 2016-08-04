//
//  DataManager.swift
//  Gainscope
//
//  Created by Tyler Angert on 7/27/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import Foundation
import AFNetworking
import NotificationCenter

class DataManager {
    
    //Singleton
    static let sharedInstance = DataManager()
    
    //different notifications with objects sent
    //need to place inside of functions
    
    //map data
    //NSNotificationCenter.defaultCenter().postNotificationName("updateMapData", object: nil)

        var yelpClient: YelpClient!
        let yelpConsumerKey = "uDLkplNRgQcI9sM0CMnHxg"
        let yelpConsumerSecret = "2-34WuoVmOzCEs8NNWrdW0oAECc"
        let yelpToken = "yULdo-JwtBGgi1uNRvW-Yprll86x2JlU"
        let yelpTokenSecret = "wvgz30HjKdqR9Ul0qKSyDd4ASCM"

    
    var coffeeList = [Business]()
    var gymsList = [Business]()
    var foodList = [Business]()
    var allLists = [[Business]]()
    
    
    //function to perform all searches at once and preload data into business arrays
    func performSearches() {
        
        yelpClient = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        
        self.yelpClient.searchWithTerm("coffee", completion: { (results: [Business]!, error: NSError!) -> Void in
            for business in results {
                self.addItem(business, searchTerm: "coffee")
            }
        })
        
        self.yelpClient.searchWithTerm("gyms", completion: { (results: [Business]!, error: NSError!) -> Void in
            for business in results {
                self.addItem(business, searchTerm: "gyms")
            }
        })
        
        self.yelpClient.searchWithTerm("food", completion: { (results: [Business]!, error: NSError!) -> Void in
            for business in results {
                self.addItem(business, searchTerm: "food")
            }
        })
    }
    
    //adds a business item to each respective list of data.
    func addItem(item: Business, searchTerm: String) {
        
        if searchTerm == "coffee" {
            self.coffeeList.append(item)
            NSNotificationCenter.defaultCenter().postNotificationName("updateTableViewData", object: coffeeList)
        }
        if searchTerm == "gyms" {
            self.gymsList.append(item)
            NSNotificationCenter.defaultCenter().postNotificationName("updateTableViewData", object: gymsList)
            
        }
        if searchTerm == "food" {
            self.foodList.append(item)
            NSNotificationCenter.defaultCenter().postNotificationName("updateTableViewData", object: foodList)
        }
        
    }
    
    //compiles all data into an organized 2-d business array for easy data access.
    func addAllLists(lists: [Business]...) {
        for list in lists {
            self.allLists.append(list)
        }
    }
    
    //removes Items from a  selected list.
    func removeSpecificListItems(var list: [Business]) {
        list.removeAll()
    }

    }