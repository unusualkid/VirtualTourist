////
////  CoreDataCollectionViewController.swift
////  VirtualTourist
////
////  Created by Kenneth Chen on 11/1/17.
////  Copyright © 2017 Cotery. All rights reserved.
////
//
//import UIKit
//import CoreData
//
//
////TODO: Finish this class
//class CoreDataCollectionViewController: UICollectionViewController {
//    
//    // MARK: Properties
//
//    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
//        didSet {
//            // Whenever the frc changes, we execute the search and
//            // reload the collection
//            fetchedResultsController?.delegate = self
//            executeSearch()
//            collectionView?.reloadData()
//        }
//    }
//
////    // MARK: Initializers
////
////    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, layout: UICollectionViewLayout) {
////        fetchedResultsController = fc
////        super.init(collectionViewLayout: layout)
////    }
////
////    // Do not worry about this initializer. It has to be implemented
////    // because of the way Swift interfaces with an Objective C
////    // protocol called NSArchiving. It's not relevant.
////    required init?(coder aDecoder: NSCoder) {
////        super.init(coder: aDecoder)
////    }
////
//}
//
//// MARK: - CoreDataCollectionViewController (Fetches)
//
//extension CoreDataCollectionViewController {
//    
//    func executeSearch() {
//        if let fc = fetchedResultsController {
//            do {
//                try fc.performFetch()
//            } catch let e as NSError {
//                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
//            }
//        }
//    }
//}
//
//extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate {
//}

