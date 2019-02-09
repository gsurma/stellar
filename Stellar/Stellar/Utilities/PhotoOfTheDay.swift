//
//  PhotoOfTheDay.swift
//  Spacetagram
//
//  Created by Greg on 1/26/19.
//  Copyright © 2019 GS. All rights reserved.
//

import Foundation
import UIKit

struct PhotoOfTheDay {
    
    var image: UIImage
    var title: String
    var date: String
    var explanation: String
}

final class PhotoOfTheDayProvider {

    class func get(forDate: String, completion: @escaping (PhotoOfTheDay?) -> ()) {

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
                            completion(potd)
                            return
                        }
                    }
                } catch let error {
                    print(error)
                }
                completion(nil)
            }
            task.resume()
        } else {
            completion(nil)
        }
    }
}
