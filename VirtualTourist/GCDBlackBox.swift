//
//  GCDBlackBox.swift
//  VirtualTourist
//
//  Created by Kenneth Chen on 11/1/17.
//  Copyright © 2017 Cotery. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
