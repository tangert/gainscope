//
//  DataManager.swift
//  Gainscope
//
//  Created by Tyler Angert on 7/27/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import Foundation
import NotificationCenter

class DataManager {
    
    //Singleton
    static let sharedInstance = DataManager()
    var listItems = [Business]()
    
    func addItem(item: Business) {
        self.listItems.append(item)
        NSNotificationCenter.defaultCenter().postNotificationName("updateTableViewData", object: self.listItems)
        
        /*if listItems.count > 20 {
            //if user presses multiple buttons before data loads…
            for index in 0..<self.listItems.count - 20  {
                self.listItems.removeAtIndex(index)
                print(self.listItems.count)
                NSNotificationCenter.defaultCenter().postNotificationName("updateTableViewData", object: self.listItems)
                NSNotificationCenter.defaultCenter().postNotificationName("updateMapPins", object: nil)
                
            }
            
        }*/
    }
    
    func removeItems() {
        self.listItems.removeAll()
    }
    
    
}