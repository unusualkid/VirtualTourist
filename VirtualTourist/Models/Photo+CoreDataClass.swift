//
//  Photo+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Kenneth Chen on 11/23/17.
//  Copyright © 2017 Cotery. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    convenience init(url: String, context: NSManagedObjectContext) {
        
        // An EntityDescription is an object that has access to all
        // the information you provided in the Entity part of the model
        // you need it to create an instance of this class.
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.url = url
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
}
