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
    
    var annotationView = MKAnnotationView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.searchByLatLon()
        title = "Virtual Tourist"
        navigationItem.backBarButtonItem?.title = "Back"
    }
    
    @IBAction func testButtonPressed(_ sender: Any) {
//        print("photos: \(photos)")
//        print("photos.count: \(photos.count)")
    }
    
    func searchByLatLon() {
        print("searchByLatLon()")
        FlickrClient.sharedInstance.getImages { (photos, error) in
            print("FlickrClient.sharedInstance.getImages")
            if let photos = photos {
                print("if let photos = photos")
                performUIUpdatesOnMain {
                    print("IMAGES: \(photos)")
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
//        mapView.centerCoordinate.latitude = latitude
//        mapView.centerCoordinate.longitude = longitude
//        mapView.region.span.latitudeDelta = latitudeDelta
//        mapView.region.span.longitudeDelta = longitudeDelta
        mapView.addAnnotation(annotationView.annotation!)
        
        print("mapView.centerCoordinate.latitude: \(mapView.centerCoordinate.latitude)")
        print("mapView.centerCoordinate.latitude: \(mapView.centerCoordinate.longitude)")
        print("mapView.region.span.latitudeDelta: \(mapView.region.span.latitudeDelta)")
        print("mapView.region.span.longitudeDelta: \(mapView.region.span.longitudeDelta)")
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
//        // Set the name and image
//        cell.imageView.image = photo
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        //        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        //        detailController.photos = [self.photos[(indexPath as NSIndexPath).row]]
        //        self.navigationController!.pushViewController(detailController, animated: true)
        
    }
}


