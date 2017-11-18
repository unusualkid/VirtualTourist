//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Kenneth Chen on 11/1/17.
//  Copyright © 2017 Cotery. All rights reserved.
//

import Foundation

class FlickrClient: NSObject {
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
    
    // Create a oneline singleton
    static let sharedInstance = FlickrClient()
    
    override init() {
        super.init()
    }
    
    // Helper for creating a URL from parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Flickr.ApiScheme
        components.host = Constants.Flickr.ApiHost
        components.path = Constants.Flickr.ApiPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }

//    // Helper for creating Flickr bbox parameter
//    private func bboxString() -> String {
//        // ensure bbox is bounded by minimum and maximums
//        if let latitude = Double(latitudeTextField.text!), let longitude = Double(longitudeTextField.text!) {
//            let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
//            let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
//            let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
//            let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
//            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
//        } else {
//            return "0,0,0,0"
//        }
//    }
}
