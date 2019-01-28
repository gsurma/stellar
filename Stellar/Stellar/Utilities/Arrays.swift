//
//  Arrays.swift
//  Stellar
//
//  Created by Greg on 1/27/19.
//  Copyright © 2019 GS. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
    
    func randomize() -> Array {
        return Array(Set(self))
    }
    
    func randomElement() -> Element? {
        guard !self.isEmpty else {
            return nil
        }
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
}
