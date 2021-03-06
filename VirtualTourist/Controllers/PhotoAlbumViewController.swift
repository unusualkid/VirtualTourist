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
    var deletePicsEnabled = false
    var pin: Pin?
    var noImageFound = false
    
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
        
        setUpNavigationBar()
        
        setUpMapView()
        
        fetchedResultsController.delegate = self
        
        executeSearch()
        
        DispatchQueue.main.async{
            self.setUpCollectionViewLayout()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let fetchedPhotos = fetchedResultsController.fetchedObjects as! [Photo]?
        
        if let fetchedPhotos = fetchedPhotos {
            if fetchedPhotos.isEmpty {
                print("No image in coredata, downloading URLs from Flickr")
                downloadPhotos()
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            self.setUpCollectionViewLayout()
        }
    }
    
    @IBAction func toolButtonPressed(_ sender: Any) {
        if selectedIndexes.isEmpty {
            deleteAllPhotos()
            downloadPhotos()
            
        } else {
            deleteSelectedPhotos()
        }
        selectedIndexes.removeAll()
        updateToolButton()
    }
    
}


// Utility functions
extension PhotoAlbumViewController {
    func setUpNavigationBar() {
        title = "Virtual Tourist"
        navigationItem.backBarButtonItem?.title = "Back"
    }
    
    func setUpMapView() {
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
        
    }
    
    func setUpCollectionViewLayout() {
        let space:CGFloat = 1.0
        let dimension = (collectionView.bounds.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        
        if let _ = selectedIndexes.index(of: indexPath) {
            cell.imageView.alpha = 0.5
        } else {
            cell.imageView.alpha = 1.0
        }
    }

    func downloadPhotos() {
        FlickrClient.sharedInstance.getImages { (photos, error) in
            if let photos = photos {
                var urls = [String]()
                
                if photos.isEmpty {
                    print("photos.isEmpty")
                    DispatchQueue.main.async {
                        self.noImageLabel.isHidden = false
                    }
                }
                
                let slicedPhotos = photos[..<12]
                for photo in slicedPhotos {
                    print("photo: \(photo)")
                    let url = photo["url_m"] as! String
                    urls.append(url)
                    
                    let newPhoto = Photo(url: url, isFinishedDownloading: true, context: self.fetchedResultsController.managedObjectContext)
                    newPhoto.pin = self.pin
                }
                self.delegate.stack.save()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                self.downloadPhotosOntoCells(urls)
            } else {
                print(error ?? "empty error")
            }
        }
    }
    
    func downloadPhotosOntoCells(_ urls: [String]) {
        for url in urls {
            FlickrClient.sharedInstance.downloadPhotos(url, completionHandlerForDownloadPhotos: { (downloadedImage, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    print("url: \(url)")
                    self.executeSearch()
                    let photos = self.fetchedResultsController.fetchedObjects as! [Photo]
                    for photo in photos {
                        if url == photo.url! {
                            photo.imageData = downloadedImage as NSData?
                            let indexPath = self.fetchedResultsController.indexPath(forObject: photo)
                            print("indexPath: \(indexPath)")
                            var indexPaths = [IndexPath]()
                            indexPaths.append(indexPath!)
                            
                            DispatchQueue.main.async {
                                self.collectionView.reloadItems(at: indexPaths)
                            }
                        }
                    }
                }
            })
        }
    }
    
    func deleteAllPhotos() {
        print("in deleteAllPhotos()")
        
        executeSearch()
        for photo in (self.fetchedResultsController.fetchedObjects)! {
            self.delegate.stack.context.delete(photo as! NSManagedObject)
        }
        self.delegate.stack.save()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func deleteSelectedPhotos() {
        print("in deleteSelectedPhotos()")
        
        var photosToDelete = [Photo]()
        
        for indexPath in selectedIndexes {
            print("indexPath: \(indexPath)")
            print("indexPath.row: \(indexPath.row)")
            
            executeSearch()
            print("fetchedResultsController.object(at: indexPath): \(fetchedResultsController.object(at: indexPath))")
            photosToDelete.append(fetchedResultsController.object(at: indexPath) as! Photo)
        }
        
        for photo in photosToDelete {
            print("Removing from core data, photo: \(photo)")
            delegate.stack.context.delete(photo)
            
        }
        
        DispatchQueue.main.async {
            self.delegate.stack.save()
            self.collectionView.reloadData()
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
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("in numberOfSectionsInCollectionView()")

        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("in collectionView(_:numberOfItemsInSection)")
        
        self.executeSearch()
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("in collectionView(_:cellForItemAtIndexPath)")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumViewCell", for: indexPath) as! PhotoAlbumViewCell
        
        cell.imageView.alpha = 1.0
        cell.imageView?.image = nil
        cell.activityIndicator.hidesWhenStopped = true
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.isHidden = false
        
        let photo = fetchedResultsController.object(at: indexPath) as! Photo
        if let photoImage = photo.imageData {
            DispatchQueue.main.async {
                cell.activityIndicator.stopAnimating()
                cell.imageView?.image = UIImage(data: photoImage as Data)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("in collectionView(_:didSelectItemAtIndexPath)")
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumViewCell
        
        // If selected cell is not in selectedIndexes array, append it
        if let index = selectedIndexes.index(of: indexPath) {
            print("in removing selectedCell")
            print("index: \(index)")
            print("selectedIndexes.index(of: indexPath): \(selectedIndexes.index(of: indexPath))")
            selectedIndexes.remove(at: index)
        } else {
            print("in appending selectedCell")
            print("indexPath: \(indexPath)")
            selectedIndexes.append(indexPath)
            
        }
        print("selectedIndexes: \(selectedIndexes)")
        
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


