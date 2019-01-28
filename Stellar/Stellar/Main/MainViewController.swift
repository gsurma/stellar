//
//  MainViewController.swift
//  Spacetagram
//
//  Created by Greg on 1/26/19.
//  Copyright © 2019 GS. All rights reserved.
//

import UIKit
import Comets
import DJSemiModalViewController
import PKHUD
import Crashlytics
import UserNotifications
import StoreKit
import GoogleMobileAds

final class MainViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var potd: PhotoOfTheDay?
    private var interstitial: GADInterstitial?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        interstitial = createAndLoadInterstitial()
        setMotionEffects()
        setComets()
        setNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadPhotoOfTheDay()
    }
    
    private func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: AdMob.interstitial)
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    private func loadPhotoOfTheDay() {
        let startTime = Date().timeIntervalSince1970
        if let potd = PhotoOfTheDayProvider.get() {
            DispatchQueue.main.async {
                let elapsedTime = Date().timeIntervalSince1970-startTime
                Answers.logCustomEvent(withName: "potd_success", customAttributes: ["time": elapsedTime])
                
                self.potd = potd
                UIView.transition(with: self.imageView, duration: imageAnimationDuration, options: .transitionCrossDissolve, animations: {
                    self.imageView.image = self.potd!.image
                }, completion: { (completion) in
                    self.showAdOrAskForReviewIfPossible()
                })
            }
        } else {
            Answers.logCustomEvent(withName: "potd_error", customAttributes: nil)
            HUD.flash(.labeledError(title: "No available photo", subtitle: "Check your internet connection and try again"), delay: 2.0, completion: nil)
        }
    }
    
    private func showAdOrAskForReviewIfPossible() {
        let actionCounter = UserDefaults.standard.getActionCounter()
        if actionCounter > 0 && actionCounter % intervalBetweenPrompts == 0 {
            if [true, false].randomElement()! {
                SKStoreReviewController.requestReview()
            } else {
                if let add = self.interstitial, add.isReady {
                    add.present(fromRootViewController: self)
                }
            }
        }
    }
    
    private func setNotifications() {
        
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        center.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                Answers.logCustomEvent(withName: "notifications", customAttributes: ["permission": "false"])
            } else {
                Answers.logCustomEvent(withName: "notifications", customAttributes: ["permission": "true"])
                let content = UNMutableNotificationContent()
                content.title = "Check Your Stellar Photo of the Day! 🚀"
                content.sound = UNNotificationSound.default()
                
                var dateInfo = DateComponents()
                dateInfo.hour = 11
                dateInfo.minute = 0
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: true)
                let identifier = "Stellar Photo Of The Day Notification"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                
                center.add(request, withCompletionHandler: { (error) in
                    if let error = error {
                        Answers.logCustomEvent(withName: "notifications_error", customAttributes: ["error": error.localizedDescription])
                    } else {
                        Answers.logCustomEvent(withName: "notifications_success", customAttributes: nil)
                    }
                })
            }
        }
    }
    
    private func setComets() {
        let width = view.bounds.width
        let height = view.bounds.height
        let comets = [Comet(startPoint: CGPoint(x: 100, y: 0),
                            endPoint: CGPoint(x: 0, y: 100),
                            lineColor: UIColor.white.withAlphaComponent(0.1)),
                      Comet(startPoint: CGPoint(x: 0.4 * width, y: 0),
                            endPoint: CGPoint(x: width, y: 0.8 * width),
                            lineColor: UIColor.white.withAlphaComponent(0.01)),
                      Comet(startPoint: CGPoint(x: 0, y: 0.8 * height),
                            endPoint: CGPoint(x: width, y: 0.75 * height),
                            lineColor: UIColor.white.withAlphaComponent(0.1)),
                      Comet(startPoint: CGPoint(x: 0.4 * width, y: 0.6 * height),
                            endPoint: CGPoint(x: 0.3 * width, y: 0.5 * height),
                            lineColor: UIColor.white.withAlphaComponent(0.01))]
        
        for comet in comets {
            view.layer.addSublayer(comet.drawLine())
            view.layer.addSublayer(comet.animate())
        }
    }
    
    @IBAction func infoAction(_ sender: Any) {
        if let potd = self.potd {
            let controller = DJSemiModalViewController()

            controller.title = potd.title ?? ""

            let label = UILabel()
            label.text = potd.explanation ?? ""
            label.textColor = .white
            label.numberOfLines = 0
            label.textAlignment = .center
            controller.addArrangedSubview(view: label)
            
            controller.presentOn(presentingViewController: self, animated: true, onDismiss: { })
        }
    }
    
    private func setMotionEffects() {
        DispatchQueue.main.async {
            let min = -motionEffectsRange
            let max = motionEffectsRange
            
            let xMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
            xMotion.minimumRelativeValue = min
            xMotion.maximumRelativeValue = max
            
            let yMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
            yMotion.minimumRelativeValue = min
            yMotion.maximumRelativeValue = max
            
            let motionEffectGroup = UIMotionEffectGroup()
            motionEffectGroup.motionEffects = [xMotion,yMotion]
            
            self.imageView.addMotionEffect(motionEffectGroup)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension MainViewController: GADInterstitialDelegate {
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        Answers.logCustomEvent(withName: "interstitial_video_ad", customAttributes: ["action": "loaded"])
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        Answers.logCustomEvent(withName: "interstitial_video_ad", customAttributes: ["action": "error"])
    }
    
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        Answers.logCustomEvent(withName: "interstitial_video_ad", customAttributes: ["action": "present"])
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
        Answers.logCustomEvent(withName: "interstitial_video_ad", customAttributes: ["action": "dismiss"])
    }
}
