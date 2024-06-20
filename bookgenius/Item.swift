//
//  Item.swift
//  bookgenius
//
//  Created by Aria Han on 6/20/24.
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
