//
//  YelpClient.swift
//  Yelp
//
//  Created by Tyler Angert on 6/30/16.
//  Copyright © 2016 Angert. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AFNetworking
import BDBOAuth1Manager

//register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys

class YelpClient: BDBOAuth1RequestOperationManager  {
    
    var accessToken: String!
    var accessSecret: String!
    
    enum YelpSortMode: Int {
        case BestMatched = 0, Distance, HighestRated
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        let baseUrl = NSURL(string: "https://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret)
        
        let token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
        
        func searchWithTerm(term: String, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
            return searchWithTerm(term, sort: nil, categories: nil, deals: nil, completion: completion)
        }
        
        func searchWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, completion: ([Business]!, NSError!) -> Void) -> AFHTTPRequestOperation {
            // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
            
            let lat = PrimaryContentViewController().locationManager.location?.coordinate.latitude
            let long = PrimaryContentViewController().locationManager.location?.coordinate.longitude
            
            var parameters: [String : AnyObject] = ["term": term, "ll": "\(lat!),\(long!)"]
            
            if sort != nil {
                parameters["sort"] = sort!.rawValue
            }
            
            if categories != nil && categories!.count > 0 {
                parameters["category_filter"] = (categories!).joinWithSeparator(",")
            }
            
            if deals != nil {
                parameters["deals_filter"] = deals!
            }
            
            print(parameters)
            
            return self.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                let dictionaries = response["businesses"] as? [NSDictionary]
                if dictionaries != nil {
                    completion(Business.returnBusinesses(array: dictionaries!), nil)
                }
                }, failure: { (operation: AFHTTPRequestOperation?, error: NSError!) -> Void in
                    completion(nil, error)
            })!
        }
    
    /*
    func searchWithTerm(parameters: [String: String], success: (AFHTTPRequestOperation!, AnyObject!) -> Void, failure: ((AFHTTPRequestOperation?, NSError) -> Void)?) -> AFHTTPRequestOperation! {
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        
        return self.GET("search", parameters: parameters, success: success, failure: failure)
    }*/
    
    /*
     func searchWithTerm
     (term: String, parameters: Dictionary<String, String>? = nil, offset: Int = 0, limit: Int = 20, success: (AFHTTPRequestOperation!, AnyObject!) -> Void, failure: ((AFHTTPRequestOperation?, NSError) -> Void)?) -> AFHTTPRequestOperation!
     
     {
     var params: NSMutableDictionary =
     [
     "term": term,
     "offset": offset,
     "limit": limit
     ]
     
     for (key, value) in parameters! {
     params.setValue(value, forKey: key)
     }
     return self.GET("search", parameters: params, success: success, failure: failure)
     }*/
    
    /*
 
 class func searchWithTerm(term: String, completion: ([Business]!, NSError!) -> [(name: String?, address: String?, coordinate: CLLocationCoordinate2D?, distanceFromMe: Double?, imageURL: String?, rating: Double?, ratingImageURL: String?, phone: String?)]) {
 YelpClient.sharedInstance.searchWithTerm(term, completion: completion)
 }
 
 class func searchWithTerm(term: String, sort: YelpSortMode?, categories: [String]?, deals: Bool?, completion: ([Business]!, NSError!) ->
 
 [(name: String?, address: String?, coordinate: CLLocationCoordinate2D?, distanceFromMe: Double?, imageURL: String?, rating: Double?, ratingImageURL: String?, phone: String?)])
 
 -> Void {
 
 YelpClient.sharedInstance.searchWithTerm(term, sort: sort, categories: categories, deals: deals, completion: completion)
 }
 
 */
 
 
}

