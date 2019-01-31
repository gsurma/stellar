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
    var title: String
    var date: String
    var explanation: String
    
    init(image: UIImage, title : String, date : String, explanation: String) {
        self.image = image
        self.title = title
        self.date = date
        self.explanation = explanation
    }
    
    init?(dictionary: [String:String]) {
        if let title = dictionary["title"],
            let date = dictionary["date"],
            let explanation = dictionary["explanation"] {
            if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
                if let image = UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("\(date).png").path) {
                    self.init(image: image,
                              title: title,
                              date: date,
                              explanation: explanation)
                    return
                }
            }
        }
        return nil
    }
    
    var propertyListRepresentation: [String:String] {
        return ["title" : title, "date" : date, "explanation": explanation]
    }
}

final class PhotoOfTheDayProvider {

    class func get(forDate: String, completion: @escaping (PhotoOfTheDay?) -> ()) {
        if let potd = UserDefaults.standard.getPOTD(date: forDate) {
            Answers.logCustomEvent(withName: "cached_potd", customAttributes: nil)
            completion(potd)
            return
        }

        var image: UIImage?
        var title: String?
        var explanation: String?
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = requestTimeout
        let session = URLSession(configuration: sessionConfig)
        
        if let url = URL(string: Backend.host + "/planetary/apod?api_key=" + Backend.apiKey + "&date=" + forDate) {
            let task = session.dataTask(with: url) {(data, response, error) in
                do {
                    if let data = data as Data?, let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String : Any] {
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
                        
                        if image != nil && title != nil && explanation != nil {
                            let potd =  PhotoOfTheDay(image: image!,
                                                      title: title!,
                                                      date: forDate,
                                                      explanation: explanation!)
                            UserDefaults.standard.savePOTD(potd: potd)
                            completion(potd)
                        } else {
                            completion(nil)
                        }
                    }
                } catch let error {
                    print(error)
                    Answers.logCustomEvent(withName: "request_error", customAttributes: ["error": error.localizedDescription])
                    completion(nil)
                }
            }
            Answers.logCustomEvent(withName: "request", customAttributes: nil)
            task.resume()
        } else {
            completion(nil)
        }
    }
}
