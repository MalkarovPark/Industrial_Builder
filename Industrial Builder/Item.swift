//
//  Item.swift
//  Industrial Builder
//
//  Created by Artiom Malkarov on 06.10.2023.
//

import Foundation
import SwiftData

@Model
final class Item
{
    var timestamp: Date

    init(timestamp: Date)
    {
        self.timestamp = timestamp
    }
}
