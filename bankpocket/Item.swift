//
//  Item.swift
//  bankpocket
//
//  Created by Jun Nakarai on 2025/09/18.
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
