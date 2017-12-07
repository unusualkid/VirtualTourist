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
    
    // The point annotations will be stored in this array, and then provided to the map view.
    var annotations = [MKPointAnnotation]()
    
    var deletePinEnabled = false
    
    var selectedPin = Pin()
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        // Create a fetchrequest
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        fr.sortDescriptors = [NSSortDescriptor(key: "lat", ascending: true),
                              NSSortDescriptor(key: "lon", ascending: true)]
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.stack.context
        let frc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        return frc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Connect long press gesture to mapView
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gestureRecognizer:)))
        mapView.addGestureRecognizer(longPressGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        mapView.removeAnnotations(mapView.annotations)
        
        if let pins = fetchAnnotationsFromCoreData() {
            
            for pin in pins {
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = pin.lat
                annotation.coordinate.longitude = pin.lon
                performUIUpdatesOnMain {
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    // Display alert with error message
    private func displayAlert(errorString: String?) {
        let controller = UIAlertController()
        
        if let errorString = errorString {
            controller.message = errorString
        }
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { action in controller.dismiss(animated: true, completion: nil)
        }
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func fetchButtonPressed(_ sender: Any) {
        if let pins = fetchAnnotationsFromCoreData() {
            performUIUpdatesOnMain {
                for pin in pins {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate.latitude = pin.lat
                    annotation.coordinate.longitude = pin.lon
                    self.mapView.addAnnotation(annotation)
                }
                self.displayAlert(errorString: """
                    pins:
                    \(pins)
                    """)
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
            //            let delegate = UIApplication.shared.delegate as! AppDelegate
            let moc = fetchedResultsController.managedObjectContext
            let pin = Pin(lat: coordinates.latitude, lon: coordinates.longitude, context: moc)
            
            annotation.coordinate = coordinates
            mapView.addAnnotation(annotation)
            
            if (pin.photos?.count)! == 0 {
                FlickrClient.sharedInstance.getImages { (photos, error) in
                    print("pin: \(pin)")
                    if let photos = photos {
                        for photo in photos {
                            print("photo: \(photo)")
                            let url = URL(string: photo["url_m"] as! String)
                            
                            let newPhoto = Photo(url: String(describing: url!), context: moc)
                            
                            newPhoto.pin = pin
                            print("newPhoto: \(newPhoto)")
                        }
                        print("pin: \(pin)")
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
    func fetchAnnotationsFromCoreData() -> [Pin]? {
        do {
            fetchedResultsController.fetchRequest.predicate = nil
            try fetchedResultsController.performFetch()
        } catch let e as NSError {
            print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
        }
        let pins = fetchedResultsController.fetchedObjects as! [Pin]?
        print("fetchAnnotationsFromCoreData()")
        print("pins: \(pins)")
        return pins
    }
}

// Segue preparation
extension MapViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! PhotoAlbumViewController
        
        if segue.identifier! == "displayPinPhotos" {
            print("""
                if segue.identifier! == "displayPinPhotos"
                """)
            if let photoVC = segue.destination as? PhotoAlbumViewController {
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
                
                print("selectedPin: \(selectedPin)")
                let predicate = NSPredicate(format: "pin = %@", argumentArray: [selectedPin])
                print("predicate: \(predicate)")
                fetchRequest.predicate = predicate
                
                let delegate = UIApplication.shared.delegate as! AppDelegate
                
                // Create FetchedResultsController
                let fc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
                
                photoVC.fetchedResultsController = fc
                
            }
        }
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
        
        // Get the clicked pin from CoreData
        let moc = fetchedResultsController.managedObjectContext
        let fetchRequest = fetchedResultsController.fetchRequest
        let predicateLat = NSPredicate(format: "lat = %@", argumentArray: [(view.annotation?.coordinate.latitude)!])
        let predicateLon = NSPredicate(format: "lon = %@", argumentArray: [(view.annotation?.coordinate.longitude)!])
        let predicateLatLon = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateLat, predicateLon])
        fetchRequest.predicate = predicateLatLon
        
        if !deletePinEnabled {
            FlickrClient.sharedInstance.latitude = (view.annotation?.coordinate.latitude)!
            FlickrClient.sharedInstance.longitude = (view.annotation?.coordinate.longitude)!
            
            //            index = (mapView.annotations as NSArray).index(of: view.annotation!)
            //            print ("Annotation Index = \(index)")
            //
            //            print(view.IndexPath)
            if let pins = try? moc.fetch(fetchRequest) {
                for pin in pins {
                    selectedPin = pin as! Pin
                    print("selectedPin: \(selectedPin)")
                }
            }
            performSegue(withIdentifier: "displayPinPhotos", sender: self)
            
            
        } else {
            if let pins = try? moc.fetch(fetchRequest) {
                print("pins: \(pins)")
                for pin in pins {
                    moc.delete(pin as! NSManagedObject)
                }
            }
            
            mapView.removeAnnotation(view.annotation!)
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

