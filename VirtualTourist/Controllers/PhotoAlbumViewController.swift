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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // blockOperations for Coredata
    var blockOperations: [BlockOperation] = []
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the collection
            fetchedResultsController?.delegate = self
            executeSearch()
            collectionView?.reloadData()
        }
    }
    
    // Do not worry about this initializer. It has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: Deinit
    
    deinit {
        blockOperations.forEach { $0.cancel() }
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Virtual Tourist"
        navigationItem.backBarButtonItem?.title = "Back"
        
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        performUIUpdatesOnMain {
            self.setUpCollectionCellSize()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        performUIUpdatesOnMain {
            self.setUpCollectionCellSize()
        }
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
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        print("mapViewDidFinishLoadingMap")
    }
    
    
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        print("mapViewWillStartRenderingMap")
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController {
            return fc.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController?.object(at: indexPath) as! Photo
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumViewCell", for: indexPath) as! PhotoAlbumViewCell
        
        var imageURL: URL!
        
        if let url = photo.url {
            imageURL = URL(string: url)
        }
        
        if let imageData = try? Data(contentsOf: imageURL!) {
            performUIUpdatesOnMain {
                cell.imageView.image = UIImage(data: imageData)
            }
        }
        
        return cell
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
    
    func fetchPhotosFromCoreData() -> [Photo]? {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            let results = try delegate.stack.backgroundContext.fetch(fetchRequest) as! [Photo]
            print("results: \(results)")
            return results
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return nil
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type {
            
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            let op = BlockOperation { [weak self] in self?.collectionView.insertItems(at: [newIndexPath as IndexPath]) }
            blockOperations.append(op)
            
        case .update:
            guard let newIndexPath = newIndexPath else { return }
            let op = BlockOperation { [weak self] in self?.collectionView.reloadItems(at: [newIndexPath as IndexPath]) }
            blockOperations.append(op)
            
        case .move:
            guard let indexPath = indexPath else { return }
            guard let newIndexPath = newIndexPath else { return }
            let op = BlockOperation { [weak self] in self?.collectionView.moveItem(at: indexPath as IndexPath, to: newIndexPath as IndexPath) }
            blockOperations.append(op)
            
        case .delete:
            guard let indexPath = indexPath else { return }
            let op = BlockOperation { [weak self] in self?.collectionView.deleteItems(at: [indexPath as IndexPath]) }
            blockOperations.append(op)
            
        }
    }
    
    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        switch type {
            
        case .insert:
            let op = BlockOperation { [weak self] in self?.collectionView.insertSections(NSIndexSet(index: sectionIndex) as IndexSet) }
            blockOperations.append(op)
            
        case .update:
            let op = BlockOperation { [weak self] in self?.collectionView.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet) }
            blockOperations.append(op)
            
        case .delete:
            let op = BlockOperation { [weak self] in self?.collectionView.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet) }
            blockOperations.append(op)
            
        default: break
            
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            self.blockOperations.forEach { $0.start() }
        }, completion: { finished in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
}


