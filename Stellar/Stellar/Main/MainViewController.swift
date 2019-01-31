//
//  MainViewController.swift
//  Spacetagram
//
//  Created by Greg on 1/26/19.
//  Copyright © 2019 GS. All rights reserved.
//

import UIKit
import DJSemiModalViewController
import PKHUD
import Crashlytics

final class MainViewController: UIViewController {
    
    var date: Date!
    var potd: PhotoOfTheDay?
    var page: PageViewController!
    var infoImage: UIImage!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var infoButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "EEEE\nMMMM dd"
        let stringDate = dateFormat.string(from: date).uppercased()
        dateLabel.text = stringDate
        
        infoButton.setImage(infoImage, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadPhotoOfTheDay()
    }
    
    func loadPhotoOfTheDay() {
        guard potd == nil else { return }
        let startTime = Date().timeIntervalSince1970
        PhotoOfTheDayProvider.get(forDate: date.formattedString(format: "YYYY-MM-DD")) { (potd) in
            if let potd = potd {
                DispatchQueue.main.async {
                    let elapsedTime = Date().timeIntervalSince1970-startTime
                    Answers.logCustomEvent(withName: "potd_success", customAttributes: ["time": elapsedTime])
                    
                    self.potd = potd
                    UIView.transition(with: self.imageView,
                                      duration: imageAnimationDuration,
                                      options: .transitionCrossDissolve, animations: {
                                        self.imageView.image = potd.image
                    }, completion: { (completion) in
                        
                    })
                }
            } else {
                Answers.logCustomEvent(withName: "potd_error", customAttributes: nil)
            }
        }
    }
    
    @IBAction func infoAction(_ sender: Any) {
        if let potd = self.potd {
            let controller = DJSemiModalViewController()

            controller.title = potd.title

            let label = UILabel()
            label.text = potd.explanation
            label.textColor = .white
            label.numberOfLines = 0
            label.textAlignment = .center
            controller.addArrangedSubview(view: label)
            
            controller.presentOn(presentingViewController: self, animated: true, onDismiss: {
                UserDefaults.standard.incrementActionCounter()
                self.page.showAdOrAskForReviewIfPossible()
            })
            Answers.logCustomEvent(withName: "info_success", customAttributes: nil)

        } else {
            Answers.logCustomEvent(withName: "info_error", customAttributes: nil)
            HUD.flash(.labeledError(title: "No Data", subtitle: "Check your internet connection and try again"), delay: 2.0, completion: nil)
        }
    }
}
