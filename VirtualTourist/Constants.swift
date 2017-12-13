//
//  Constants.swift
//  VirtualTourist
//
//  Created by Kenneth Chen on 10/31/17.
//  Copyright © 2017 Cotery. All rights reserved.
//
import Foundation

struct Constants {
    
    struct Map {
        
        struct Key {
            static let Longitude = "longitude"
            static let Latitude = "latitudeKey"
            static let LongitudeDelta = "longitudeDelta"
            static let LatitudeDelta = "latitudeDelta"
            static let IsFirstLoad = "isFirstLoad"
        }
        
    }
    
    // MARK: URLs
    struct Flickr {
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
        static let SearchBBoxHalfWidth = 0.5
        static let SearchBBoxHalfHeight = 0.5
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "01c7fb4e3a07f5b087481bf99afbcb6c"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = 1        /* 1 means "yes" */
        static let MediumURL = "url_m"
        static let UseSafeSearch = 1
        static let PerPage = 24
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
}
