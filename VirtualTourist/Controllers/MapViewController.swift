//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Kenneth Chen on 10/30/17.
//  Copyright © 2017 Cotery. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deletePinLabel: UILabel!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    // The point annotations will be stored in this array, and then provided to the map view.
    var annotations = [MKPointAnnotation]()
    
    var deletePinEnabled = false
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect long press gesture to mapView
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureRecognizer:)))
        mapView.addGestureRecognizer(longPressGesture)
        
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        
        fr.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true),
                              NSSortDescriptor(key: "lon", ascending: true)]
        
        // Create the FetchedResultsController
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        mapView.removeAnnotations(mapView.annotations)
        
        if let pins = fetchAnnotationsFromCoreData() {
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = pin.lat
                annotation.coordinate.longitude = pin.lon
                mapView.addAnnotation(annotation)
            }
        }
    }

    @IBAction func editButtonPressed(_ sender: Any) {
        if view.frame.origin.y == 0 {
            view.frame.origin.y = -50
            deletePinLabel.isHidden = false
            deletePinEnabled = true
        } else {
            view.frame.origin.y = 0
            deletePinLabel.isHidden = true
            deletePinEnabled = false
        }

    }
    
    // Drop and add pin when long press gesture detected
    @objc func longPress(gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()

            let pin = Pin(lat: coordinates.latitude, lon: coordinates.longitude, context: delegate.stack.context)
            
            annotation.coordinate = coordinates
            mapView.addAnnotation(annotation)
            
            if (pin.photos?.count)! == 0 {
                FlickrClient.sharedInstance.getImages { (photos, error) in
                    print("FlickrClient.sharedInstance.getImages")
                    if let photos = photos {
                        for photo in photos {
                            print("photo: \(photo)")
                            let url = URL(string: photo["url_m"] as! String)
                            let newPhoto = Photo(url: String(describing: url), context: self.delegate.stack.context)

                            newPhoto.pin = pin
                            print("newPhoto: \(newPhoto)")
                        }
                    } else {
                        print(error ?? "empty error")
                    }
                }
            }
        }
    }
}

// CoreData functions
extension MapViewController: NSFetchedResultsControllerDelegate {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
    func fetchAnnotationsFromCoreData() -> [Pin]? {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
            let results = try delegate.stack.backgroundContext.fetch(fetchRequest) as! [Pin]
            print("results: \(results)")
            return results
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
}

extension MapViewController {
    func searchImageLatLon(pin: Pin) {
        
    }
}

// Map delegate functions
extension MapViewController: MKMapViewDelegate {
    
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
    
    // Segue to the PhotoAlbumView when a pin is clicked or if the edit mode is on, delete the pin
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if !deletePinEnabled {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
            FlickrClient.sharedInstance.latitude = (view.annotation?.coordinate.latitude)!
            FlickrClient.sharedInstance.longitude = (view.annotation?.coordinate.longitude)!
            
            self.navigationController!.pushViewController(controller, animated: true)
        } else {
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
//            let collectionArray = [(view.annotation?.coordinate.latitude)!, (view.annotation?.coordinate.longitude)!]
//            print("collectionArray: \(collectionArray)")
            
            let predicateLat = NSPredicate(format: "lat = %@", argumentArray: [(view.annotation?.coordinate.latitude)!])
            let predicateLon = NSPredicate(format: "lon = %@", argumentArray: [(view.annotation?.coordinate.longitude)!])
            let predicateLatLon = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLat, predicateLon])
            print("predicate: \(predicateLatLon)")
            fetchRequest.predicate = predicateLatLon
            
            //TODO: this line crashes
            if let pin = try? delegate.stack.backgroundContext.fetch(fetchRequest) as! Pin {
                print("pin: \(pin)")
                delegate.stack.backgroundContext.delete(pin)
            }
            mapView.removeAnnotation(view.annotation!)
            
//            if let pins = fetchAnnotationsFromCoreData() {
//                for pin in pins {
//                    if pin.lat == view.annotation?.coordinate.latitude, pin.lon == view.annotation?.coordinate.longitude {
//                        fetchedResultsController?.fetchedObjects.
//                    }
//                }
//            }

        }
        
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        print("mapViewWillStartRenderingMap")
        print("UserDefaults.standard.bool(forKey: Constants.Map.Key.IsFirstLoad): \(UserDefaults.standard.bool(forKey: Constants.Map.Key.IsFirstLoad)) ")
        if UserDefaults.standard.bool(forKey: Constants.Map.Key.IsFirstLoad) {
            if let latitude = UserDefaults.standard.value(forKey: Constants.Map.Key.Latitude),
                let longitude = UserDefaults.standard.value(forKey: Constants.Map.Key.Longitude),
                let latitudeDelta = UserDefaults.standard.value(forKey: Constants.Map.Key.LongitudeDelta),
                let longitudeDelta = UserDefaults.standard.value(forKey: Constants.Map.Key.LongitudeDelta) {
                mapView.centerCoordinate.latitude = latitude as! CLLocationDegrees
                mapView.centerCoordinate.longitude = longitude as! CLLocationDegrees
                mapView.region.span.latitudeDelta = latitudeDelta as! CLLocationDegrees
                mapView.region.span.longitudeDelta = longitudeDelta as! CLLocationDegrees
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("mapView regionDidChange")
        UserDefaults.standard.set(false, forKey: Constants.Map.Key.IsFirstLoad)
        UserDefaults.standard.set(mapView.centerCoordinate.latitude, forKey: Constants.Map.Key.Latitude)
        UserDefaults.standard.set(mapView.centerCoordinate.longitude, forKey: Constants.Map.Key.Longitude)
        UserDefaults.standard.set(mapView.region.span.latitudeDelta, forKey: Constants.Map.Key.LatitudeDelta)
        UserDefaults.standard.set(mapView.region.span.longitudeDelta, forKey: Constants.Map.Key.LongitudeDelta)
        UserDefaults.standard.synchronize()
    }
}

