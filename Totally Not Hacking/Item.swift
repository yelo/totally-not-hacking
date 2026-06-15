//
//  Item.swift
//  Totally Not Hacking
//
//  Created by Jimmy Kumpulainen on 2026-06-15.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
