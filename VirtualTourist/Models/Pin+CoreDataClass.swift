//
//  Pin+CoreDataClass.swift
//  VirtualTourist
//
//  Created by Kenneth Chen on 10/31/17.
//  Copyright © 2017 Cotery. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Pin)
public class Pin: NSManagedObject {
    convenience init(id: String, context: NSManagedObjectContext) {
        self.init()
    }
}
