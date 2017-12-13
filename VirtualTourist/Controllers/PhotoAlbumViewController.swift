//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Kenneth Chen on 10/30/17.
//  Copyright © 2017 Cotery. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var noImageLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var selectedIndexes = [IndexPath]()
    var photos = [Photo]()
    var deletePicsEnabled = false
    var pinHasNoImage = false
    var pin: Pin?
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    // Keep the changes. We will keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
        print("fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>")
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "url", ascending: true)]
        
        if let pin = pin {
            let predicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
            print("predicate: \(predicate)")
            fetchRequest.predicate = predicate
        }
        
        // Create FetchedResultsController
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: delegate.stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Virtual Tourist"
        navigationItem.backBarButtonItem?.title = "Back"
        
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.removeAnnotations(mapView.annotations)
        
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: FlickrClient.sharedInstance.latitude, longitude: FlickrClient.sharedInstance.longitude)
        
        mapView.centerCoordinate = coordinate
        
        // Here we create the annotation and set its coordiate, title, and subtitle properties
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
        mapView.setRegion(region, animated: true)
        
        mapView.addAnnotation(annotation)
        
        performUIUpdatesOnMain {
            self.setUpCollectionCellSize()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        executeSearch()
        
        let fetchedPhotos = fetchedResultsController.fetchedObjects as! [Photo]?
        
        if let fetchedPhotos = fetchedPhotos {
            print("in if let fetchedPhotos = fetchedPhotos")
            if fetchedPhotos.isEmpty {
                print("No image in coredata, downloading URLs from Flickr")
                downloadPhotoURL()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } else {
                print("else load image from coredata")
                for photo in fetchedPhotos {
                    self.photos.append(photo)
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
        

        
        
        // TODO: set noImageLabel to not hidden in this VC
        // If the pin has no related photos in core data, set pinHasNoImage to true
        if fetchedResultsController.fetchedObjects?.count == 0 {
            pinHasNoImage = true
        } else {
            pinHasNoImage = false
        }

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        performUIUpdatesOnMain {
            self.setUpCollectionCellSize()
        }
    }
    
    @IBAction func toolButtonPressed(_ sender: Any) {
        if selectedIndexes.isEmpty {
            deleteAllPhotos()
            
            print("All images deleted.")
            FlickrClient.sharedInstance.getImages { (photos, error) in
                if let photos = photos {
                    for photo in photos {
                        let url = URL(string: photo["url_m"] as! String)
                        let newPhoto = Photo(url: String(describing: url!), isFinishedDownloading: true, context: self.fetchedResultsController.managedObjectContext)
                        newPhoto.pin = self.pin
                        
                        self.photos.append(newPhoto)
                    }
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    delegate.stack.save()
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                } else {
                    print(error ?? "empty error")
                }
            }
            
        } else {
            deleteSelectedPhotos()
        }
        updateToolButton()
    }
    
}


// Utility functions
extension PhotoAlbumViewController {
    // Set up cell size to auto adjust based on the device's width
    func setUpCollectionCellSize() {
        let space:CGFloat = 1.0
        let dimension = (collectionView.bounds.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func updateToolButton() {
        if selectedIndexes.count > 0 {
            toolButton.title = "Delete Selected Pictures"
            deletePicsEnabled = true
        } else {
            toolButton.title = "New Collection"
            deletePicsEnabled = false
        }
    }
    
    func configureCell(_ cell: PhotoAlbumViewCell, atIndexPath indexPath: IndexPath) {
        print("in configureCell")
        // If the cell is "selected", its color panel is grayed out
        // we use the Swift `find` function to see if the indexPath is in the array
        
        if let _ = selectedIndexes.index(of: indexPath) {
            cell.imageView.alpha = 0.5
        } else {
            cell.imageView.alpha = 1.0
        }
    }
    
    func downloadPhotoURL() {
        FlickrClient.sharedInstance.getImages { (photos, error) in
            if let photos = photos {
                for photo in photos {
                    print("photo: \(photo)")
                    let url = URL(string: photo["url_m"] as! String)
                    
                    let newPhoto = Photo(url: String(describing: url!), isFinishedDownloading: true, context: self.fetchedResultsController.managedObjectContext)
                    
                    newPhoto.pin = self.pin
                    self.photos.append(newPhoto)
                }
                self.delegate.stack.save()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } else {
                print(error ?? "empty error")
            }
        }
    }
    
    func deleteAllPhotos() {
        for photo in (fetchedResultsController.fetchedObjects)! {
            let context = fetchedResultsController.managedObjectContext
            context.delete(photo as! NSManagedObject)
        }
        photos.removeAll()
    }
    
    func deleteSelectedPhotos() {
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            photos.remove(at: indexPath.row)
            photosToDelete.append(fetchedResultsController.object(at: indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            fetchedResultsController.managedObjectContext.delete(photo)
        }
        
        selectedIndexes = [IndexPath]()
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
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("in numberOfSectionsInCollectionView()")
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("in collectionView(_:numberOfItemsInSection)")
        print("photos.count: \(photos.count)")
        
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("in collectionView(_:cellForItemAtIndexPath)")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumViewCell", for: indexPath) as! PhotoAlbumViewCell
        
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.isHidden = false
        
        let photo = photos[indexPath.row]
        var imageURL: URL!
        
        if let url = photo.url {
            imageURL = URL(string: url)
        }
        
        if let imageURL = imageURL {
            if let imageData = try? Data(contentsOf: imageURL) {
                performUIUpdatesOnMain {
                    cell.activityIndicator.stopAnimating()
                    cell.activityIndicator.isHidden = true
                    cell.imageView.image = UIImage(data: imageData)
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("in collectionView(_:didSelectItemAtIndexPath)")
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumViewCell
        
        // If selected cell is not in selectedIndexes array, append it
        if let index = selectedIndexes.index(of: indexPath) {
            selectedIndexes.remove(at: index)
        } else {
            selectedIndexes.append(indexPath)
        }
        
        // Tint the selected cell
        configureCell(cell, atIndexPath: indexPath)
        
        updateToolButton()
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func executeSearch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let e as NSError {
            print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
        }
    }
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create
    // three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
        
        print("in controllerWillChangeContent")
    }
    
    // The second method may be called multiple times, once for each Photo object that is added, deleted, or changed.
    // We store the index paths into the three arrays.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            
        case .insert:
            print("Insert an item")
            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            print("Delete an item")
            // Here we are noting that a Color instance has been deleted from Core Data. We remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            print("Update an item.")
            // We don't expect Color instances to change after they are created. But Core Data would
            // notify us of changes if any occured. This can be useful if you want to respond to changes
            // that come about after data is downloaded. For example, when an image is downloaded from
            // Flickr in the Virtual Tourist app
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
            //default:
            //break
        }
    }
    
    
    // This method is invoked after all of the changed objects in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). We now need to loop through the
    // arrays and perform the changes.
    //
    // The most interesting thing about the method is the collection view's "performBatchUpdates" method.
    // Notice that all of the changes are performed inside a closure that is handed to the collection view.
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        print("in controllerDidChangeContent. changes.count: \(insertedIndexPaths.count + deletedIndexPaths.count)")
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
}


