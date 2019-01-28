//
//  UserDefaults.swift
//  Stellar
//
//  Created by Greg on 1/27/19.
//  Copyright © 2019 GS. All rights reserved.
//

import Foundation
import Crashlytics

extension UserDefaults {
    
    enum Key: String {
        case ActionCounter = "ActionCounter"
    }

    func incrementActionCounter() {
        let old = getActionCounter()
        let new = old + 1
        UserDefaults.standard.set(new, forKey: Key.ActionCounter.rawValue)
        Answers.logCustomEvent(withName: "action_counter", customAttributes: ["count" : "\(new)"])
        UserDefaults.standard.synchronize()
    }
    
    func getActionCounter() -> Int {
        return UserDefaults.standard.integer(forKey: Key.ActionCounter.rawValue)
    }
}
