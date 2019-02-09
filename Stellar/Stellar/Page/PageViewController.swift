//
//  PageViewController.swift
//  Stellar
//
//  Created by Greg on 1/28/19.
//  Copyright © 2019 GS. All rights reserved.
//

import UIKit
import Comets

final class PageViewController: UIPageViewController {
    
    var todayDate = Date()
    var pages = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPages()
        setComets()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
    }
    
    func setPages() {
        pages = getPages()
        
        dataSource = self
        delegate = self
        
        if let last = pages.last {
            setViewControllers([last], direction: .forward, animated: true, completion: nil)
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
        if Date().formattedString(format: defaultDateFormat) != todayDate.formattedString(format: defaultDateFormat) {
            todayDate = Date()
            setPages()
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
