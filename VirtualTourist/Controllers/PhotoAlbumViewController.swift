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
    
    var annotationView = MKAnnotationView()
    var photos = [UIImage]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.searchByLatLon()
        title = "Virtual Tourist"
        navigationItem.backBarButtonItem?.title = "Back"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space:CGFloat = 1.0
        let dimension = (collectionView.bounds.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
//        flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
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
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumViewCell", for: indexPath) as! PhotoAlbumViewCell
        let photo = self.photos[(indexPath as NSIndexPath).row]
        print("photo: \(photo)")

        // Set the name and image
        cell.imageView.image = photo
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        //        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        //        detailController.photos = [self.photos[(indexPath as NSIndexPath).row]]
        //        self.navigationController!.pushViewController(detailController, animated: true)
        
    }
}


