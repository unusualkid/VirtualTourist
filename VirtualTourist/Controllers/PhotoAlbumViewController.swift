//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Kenneth Chen on 10/30/17.
//  Copyright © 2017 Cotery. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var photos = [UIImage]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        self.searchByLatLon()
        title = "Virtual Tourist"
        navigationItem.backBarButtonItem?.title = "Back"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let space:CGFloat = 1.0
//        let dimension = (collectionView.bounds.size.width - (2 * space)) / 3.0
//        flowLayout.minimumInteritemSpacing = space
//        flowLayout.minimumLineSpacing = space
        flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
//        flowLayout.estimatedItemSize = CGSize(width: dimension, height: dimension)
    }
    
    func searchByLatLon() {
        print("searchByLatLon()")
        FlickrClient.sharedInstance.getImages { (photos, error) in
            print("FlickrClient.sharedInstance.getImages")
            if let photos = photos {
                print("if let photos = photos")
                
                for photo in photos {
                    // if an image exists at the url, set the image and title
                    let imageURL = URL(string: photo["url_m"] as! String)
                    
                    if let imageData = try? Data(contentsOf: imageURL!) {
                        let image = UIImage(data: imageData)
                        performUIUpdatesOnMain {
                            self.photos.append(image!)
                            self.collectionView.reloadData()
                        }
                    }
                    //                    print("IMAGES: \(photos)")
                }
            } else {
                print("else")
                print(error ?? "empty error")
            }
        }
    }
}

extension PhotoAlbumViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        print("mapViewWillStartRenderingMap")
        
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: FlickrClient.sharedInstance.latitude, longitude: FlickrClient.sharedInstance.longitude)
        
        mapView.centerCoordinate = coordinate
//
//        mapView.centerCoordinate.latitude = FlickrClient.sharedInstance.latitude
//        mapView.centerCoordinate.longitude = FlickrClient.sharedInstance.longitude
//

        
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        //        mapView.centerCoordinate = coordinate
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
        mapView.setRegion(region, animated: true)
        
        mapView.addAnnotation(annotation)
        
        print("mapView.centerCoordinate.latitude: \(mapView.centerCoordinate.latitude)")
        print("mapView.centerCoordinate.latitude: \(mapView.centerCoordinate.longitude)")
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
//        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumViewCell", for: indexPath) as! PhotoAlbumViewCell
//        let photo = self.photos[(indexPath as NSIndexPath).row]
//        print("photo: \(photo)")
//
//        // Set the name and image
//        cell.imageView.image = photo
        
        return cell
    }
    
    

}


