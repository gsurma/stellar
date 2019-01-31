//
//  PageViewController.swift
//  Stellar
//
//  Created by Greg on 1/28/19.
//  Copyright © 2019 GS. All rights reserved.
//

import UIKit
import StoreKit
import Crashlytics
import UserNotifications
import Comets

final class PageViewController: UIPageViewController {
    
    var todayDate = Date()
    var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNotifications()
        setEverything()
        setComets()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    func setEverything() {
        pages = getPages()
        
        dataSource = self
        delegate = self
        
        if let last = pages.last {
            setViewControllers([last], direction: .forward, animated: true, completion: nil)
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
        
        let comets = [Comet(startPoint: CGPoint(x: 0.4 * width, y: 0),
                            endPoint: CGPoint(x: width, y: 0.8 * width),
                            lineColor: UIColor.white.withAlphaComponent(0.01)),
                      Comet(startPoint: CGPoint(x: 0, y: CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * height),
                            endPoint: CGPoint(x: width, y: 0.75 * height),
                            lineColor: UIColor.white.withAlphaComponent(0.1)),
                      Comet(startPoint: CGPoint(x: 500, y: CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * height),
                            endPoint: CGPoint(x: width, y: 0.5 * height),
                            lineColor: UIColor.white.withAlphaComponent(0.1)),
                      Comet(startPoint: CGPoint(x: CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * width, y: 0.6 * height),
                            endPoint: CGPoint(x: 0.3 * width, y: CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * height),
                            lineColor: UIColor.white.withAlphaComponent(0.01))]
        
        for comet in comets {
            view.layer.addSublayer(comet.drawLine())
            view.layer.addSublayer(comet.animate())
        }
    }
    
    @objc func applicationDidBecomeActive() {
        if Date().formattedString(format: "YYYY-MM-DD") != todayDate.formattedString(format: "YYYY-MM-DD") {
            todayDate = Date()
            setEverything()
        }
    }
    
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    func getPages() -> [UIViewController] {
        var randomIndices = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].randomize()
        var controllers = [UIViewController]()
        var date = todayDate
        for i in 0..<lastDaysToShow {
            let vc = self.getViewController(withIdentifier: "MainViewController") as! MainViewController
            vc.page = self
            vc.date = date
            vc.infoImage = UIImage(named: "button_\(randomIndices[i])")
            vc.view.layoutIfNeeded()
            vc.loadPhotoOfTheDay()
            controllers.append(vc)
            date = date.yesterday()
        }
        return controllers.reversed()
    }
    
    func showAdOrAskForReviewIfPossible() {
        let actionCounter = UserDefaults.standard.getActionCounter()
        if actionCounter > 0 && actionCounter % intervalBetweenPrompts == 0 {
            if [true, false].randomElement()! {
                SKStoreReviewController.requestReview()
            } else {
                showAppPromptAd()
            }
        }
    }
    
    func showAppPromptAd() {
        let alert = UIAlertController(title: "Hungry for new challenges?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes!", style: .cancel, handler: { action in
            Answers.logCustomEvent(withName: "app_prompt_ad", customAttributes: ["answer": 1])
            self.showAppProduct()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            Answers.logCustomEvent(withName: "app_prompt_ad", customAttributes: ["answer": 0])
        }))
        self.present(alert, animated: true)
    }
    
    private func showAppProduct() {
        guard let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as? String else { return }
        let randomAppAdIdentifier = appAdIds[Int(arc4random_uniform(UInt32(appAdIds.count)))]
        Answers.logCustomEvent(withName: "app_ad", customAttributes: ["id": String(randomAppAdIdentifier)])
        let vc: SKStoreProductViewController = SKStoreProductViewController()
        let params = [SKStoreProductParameterITunesItemIdentifier:randomAppAdIdentifier,
                      SKStoreProductParameterAffiliateToken:appName] as [String : Any]
        vc.delegate = self
        vc.loadProduct(withParameters: params, completionBlock: nil)
        self.present(vc, animated: true) { () -> Void in }
    }
    
    override func viewDidLayoutSubviews() {
        for subView in self.view.subviews {
            if subView is UIScrollView {
                subView.frame = self.view.bounds
            } else if subView is UIPageControl {
                self.view.bringSubview(toFront: subView)
            }
        }
        super.viewDidLayoutSubviews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension PageViewController: SKStoreProductViewControllerDelegate {
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return nil }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard pages.count > nextIndex else { return nil }
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pages.count-1
    }
}

extension PageViewController: UIPageViewControllerDelegate { }
