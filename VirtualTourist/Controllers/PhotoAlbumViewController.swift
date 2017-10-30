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
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var toolButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Virtual Tourist"
        navigationItem.backBarButtonItem?.title = "Back"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PhotoAlbumViewController: UICollectionViewDelegate {
    
}
