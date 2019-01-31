//
//  Dates.swift
//  Stellar
//
//  Created by Greg on 1/28/19.
//  Copyright © 2019 GS. All rights reserved.
//

import Foundation

extension Date {
    
    func tomorrow() -> Date {
        return self.addingTimeInterval(1*24*60*60)
    }
    
    func yesterday() -> Date {
        return self.addingTimeInterval(-1*24*60*60)
    }
    
    func formattedString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
