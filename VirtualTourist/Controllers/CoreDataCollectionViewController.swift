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
//class CoreDataCollectionViewController: UICollectionViewController {
//    
//    var blockOperations: [BlockOperation] = []
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
//    // MARK: Initializers
//    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, layout: UICollectionViewLayout) {
//        fetchedResultsController = fc
//        super.init(collectionViewLayout: layout)
//    }
//    
//    // Do not worry about this initializer. It has to be implemented
//    // because of the way Swift interfaces with an Objective C
//    // protocol called NSArchiving. It's not relevant.
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
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
//
//// MARK: - CoreDataCollectionViewController (Collection Data Source)
//
//extension CoreDataCollectionViewController {
//    
//    override func numberOfSections(in collectionView: UICollectionView) -> Int {
//        if let fc = fetchedResultsController {
//            return (fc.sections?.count)!
//        } else {
//            return 0
//        }
//    }
//    
////    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////        if let fc = fetchedResultsController {
////            return fc.sections![section].numberOfObjects
////        } else {
////            return 0
////        }
////    }
//    
////    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
////        return 3
////    }
////    
////    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
////        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumViewCell", for: indexPath) as! PhotoAlbumViewCell
////        
////        return cell
////    }
//    
//}
//
//// MARK: - CoreCollectionViewController: NSFetchedResultsControllerDelegate
//
//extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate {
//    
//    func controllerWillChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        blockOperations.removeAll(keepingCapacity: false)
//    }
//    
//    
//    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeObject anObject: AnyObject, atIndexPath indexPath: IndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        
//        if type == .insert {
//            print("Insert Object: \(newIndexPath)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.insertItems(at: [newIndexPath!])
//                    }
//                })
//            )
//        }
//        else if type == .update {
//            print("Update Object: \(indexPath)")
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.reloadItems(at: [indexPath!])
//                    }
//                })
//            )
//        }
//        else if type == .move {
//            print("Move Object: \(indexPath)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.moveItem(at: indexPath!, to: newIndexPath!)
//                    }
//                })
//            )
//        }
//        else if type == .delete {
//            print("Delete Object: \(indexPath)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.deleteItems(at: [indexPath!])
//                    }
//                })
//            )
//        }
//    }
//    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        
//        if type == .insert {
//            print("Insert Section: \(sectionIndex)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
//                    }
//                })
//            )
//        }
//        else if type == .update {
//            print("Update Section: \(sectionIndex)")
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
//                    }
//                })
//            )
//        }
//        else if type == .delete {
//            print("Delete Section: \(sectionIndex)")
//            
//            blockOperations.append(
//                BlockOperation(block: { [weak self] in
//                    if let this = self {
//                        this.collectionView!.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
//                    }
//                })
//            )
//        }
//    }
//    
//    func controllerDidChangeContent(controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        collectionView!.performBatchUpdates({ () -> Void in
//            for operation: BlockOperation in self.blockOperations {
//                operation.start()
//            }
//        }, completion: { (finished) -> Void in
//            self.blockOperations.removeAll(keepingCapacity: false)
//        })
//    }
//}
//
