//
//  PhotoOfTheDay.swift
//  Spacetagram
//
//  Created by Greg on 1/26/19.
//  Copyright © 2019 GS. All rights reserved.
//

import Foundation
import UIKit
import Crashlytics

struct PhotoOfTheDay {
    
    var image: UIImage
    var title: String?
    var date: String?
    var copyright: String?
    var explanation: String?
}

final class PhotoOfTheDayProvider {
    
    class func get() -> PhotoOfTheDay? {
        
        let semaphore = DispatchSemaphore(value: 0)
        
        var image: UIImage?
        var title: String?
        var date: String?
        var copyright: String?
        var explanation: String?
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = requestTimeout
        let session = URLSession(configuration: sessionConfig)
        
        if let url = URL(string: Backend.host + "/planetary/apod?api_key=" + Backend.apiKey) as URL? {
            let task = session.dataTask(with: url) {(data, response, error) in
                do {
                    if let data = data as Data?, let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String : Any] {
                        if let aCopyright = json["copyright"] as? String {
                            copyright = aCopyright
                        }
                        if let aDate = json["date"] as? String {
                            date = aDate
                        }
                        if let aExplanation = json["explanation"] as? String {
                            explanation = aExplanation
                        }
                        if let aTitle = json["title"] as? String {
                            title = aTitle
                        }
                        if let hdurl = json["hdurl"] as? String,
                            let url = URL(string: hdurl),
                            let data = try? Data(contentsOf: url),
                            let aImage = UIImage(data: data)  {
                            image = aImage
                        }
                    }
                } catch let error {
                    print(error)
                    Answers.logCustomEvent(withName: "request_error", customAttributes: ["error": error.localizedDescription])
                }
                semaphore.signal()
            }
            Answers.logCustomEvent(withName: "request", customAttributes: nil)
            task.resume()
            semaphore.wait()
            if image != nil {
                return PhotoOfTheDay(image: image!,
                                       title: title,
                                       date: date,
                                       copyright: copyright,
                                       explanation: explanation)
            }
        }
        return nil
    }
}
