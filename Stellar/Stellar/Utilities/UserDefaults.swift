//
//  UserDefaults.swift
//  Stellar
//
//  Created by Greg on 1/27/19.
//  Copyright © 2019 GS. All rights reserved.
//

import Foundation
import Crashlytics
import UIKit

extension UserDefaults {
    
    enum Key: String {
        case ActionCounter = "ActionCounter"
        case LaunchDate = "LaunchDate"
    }
    
    func setLaunchDate() {
        if getLaunchDate() == nil {
            let date = Date().formattedString(format: "YYYY-MM-DD")
            UserDefaults.standard.set(date, forKey: Key.LaunchDate.rawValue)
            Answers.logCustomEvent(withName: "launch_date", customAttributes: ["date" : date])
            UserDefaults.standard.synchronize()
        }
    }
    
    func getLaunchDate() -> String? {
        return UserDefaults.standard.string(forKey: Key.LaunchDate.rawValue)
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
    
    func removeOldPOTD() {
        if let launchDate = getLaunchDate() {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-DD"
            if let lowerBoundDate = dateFormatter.date(from: launchDate) {
                let upperBoundDate = Date().addingTimeInterval(TimeInterval(-lastDaysToShow*24*60*60))
                
                var date = lowerBoundDate
                while date < upperBoundDate {
                    print("removing \(date)")
                    let dateString = date.formattedString(format: "YYYY-MM-DD")
                    Answers.logCustomEvent(withName: "cleanup", customAttributes: ["date" : dateString])
                    UserDefaults.standard.removeObject(forKey: dateString)
                    if let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL, let url = directory.appendingPathComponent("\(dateString).png") {
                        do {
                            try FileManager.default.removeItem(at: url)
                        } catch {
                            Answers.logCustomEvent(withName: "cleanup_error", customAttributes: ["error" : error.localizedDescription])
                            print(error.localizedDescription)
                        }
                    }
                    date = date.addingTimeInterval(TimeInterval(1*24*60*60))
                }
            }
        }
    }
    
    func getPOTD(date: String) -> PhotoOfTheDay? {
        if let potdDict = UserDefaults.standard.dictionary(forKey: date) as? [String:String] {
            if let potd = PhotoOfTheDay(dictionary: potdDict) {
                return potd
            }
        }
        return nil
    }
    
    func savePOTD(potd: PhotoOfTheDay) {
        UserDefaults.standard.set(potd.propertyListRepresentation, forKey: potd.date)
        UserDefaults.standard.synchronize()
        
        guard let data = UIImagePNGRepresentation(potd.image) else {
            return
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return
        }
        
        do {
            try data.write(to: directory.appendingPathComponent("\(potd.date).png")!)
        } catch {
            print(error.localizedDescription)
        }
    }
}
