//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Kenneth Chen on 10/31/17.
//  Copyright © 2017 Cotery. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    convenience init(id: String, context: NSManagedObjectContext) {
        self.init()
    }
}
