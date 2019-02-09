//
//  Constants.swift
//  Spacetagram
//
//  Created by Greg on 1/26/19.
//  Copyright © 2019 GS. All rights reserved.
//

import Foundation
import UIKit

enum Backend {
    static let apiKey = "DEMO_KEY"
    static let host = "https://api.nasa.gov"
}

let defaultDateFormat = "yyy-MM-dd"
let intervalBetweenPrompts = 10
let imageAnimationDuration: TimeInterval = 1.5
let requestTimeout: TimeInterval = 5.0
let lastDaysToShow = 10

let appAdIds = [1393799957, // Achi
    1339374094, // Triangle
    1315421448, // 2048 AI
    1355485199, // Sliding Puzzle
    1035122434, // Falling Numbers X
    1326484730] // Hex
