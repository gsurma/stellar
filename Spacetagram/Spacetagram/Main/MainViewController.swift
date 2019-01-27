//
//  MainViewController.swift
//  Spacetagram
//
//  Created by Greg on 1/26/19.
//  Copyright © 2019 GS. All rights reserved.
//

import UIKit
import Comets

final class MainViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setMotionEffects()
        setComets()
        //loadPictureOfTheDay()
        
        // 0. New space
        // 1. Comets before potd https://github.com/cruisediary/Comets
        // 2. Card for extra info https://github.com/radianttap/CardPresentationController
        // 2.1 or https://github.com/nicol3a/NBBottomSheet
    }
    
    private func loadPictureOfTheDay() {
        if let potd = PictureOfTheDayProvider.get() {
            DispatchQueue.main.async {
                UIView.transition(with: self.imageView,
                                  duration: imageAnimationDuration,
                                  options: .transitionCrossDissolve,
                                  animations: { self.imageView.image = potd.image },
                                  completion: nil)
                
                // Additional data
            }
        }
    }
    
    private func setComets() {
        let width = view.bounds.width
        let height = view.bounds.height
        let comets = [Comet(startPoint: CGPoint(x: 100, y: 0),
                            endPoint: CGPoint(x: 0, y: 100),
                            lineColor: UIColor.white.withAlphaComponent(0.2)),
                      Comet(startPoint: CGPoint(x: 0.4 * width, y: 0),
                            endPoint: CGPoint(x: width, y: 0.8 * width),
                            lineColor: UIColor.white.withAlphaComponent(0.2)),
                      Comet(startPoint: CGPoint(x: 0.8 * width, y: 0),
                            endPoint: CGPoint(x: width, y: 0.2 * width),
                            lineColor: UIColor.white.withAlphaComponent(0.2)),
                      Comet(startPoint: CGPoint(x: width, y: 0.2 * height),
                            endPoint: CGPoint(x: 0, y: 0.25 * height),
                            lineColor: UIColor.white.withAlphaComponent(0.2)),
                      Comet(startPoint: CGPoint(x: 0, y: height - 0.8 * width),
                            endPoint: CGPoint(x: 0.6 * width, y: height),
                            lineColor: UIColor.white.withAlphaComponent(0.2)),
                      Comet(startPoint: CGPoint(x: width - 100, y: height),
                            endPoint: CGPoint(x: width, y: height - 100),
                            lineColor: UIColor.white.withAlphaComponent(0.2)),
                      Comet(startPoint: CGPoint(x: 0, y: 0.8 * height),
                            endPoint: CGPoint(x: width, y: 0.75 * height),
                            lineColor: UIColor.white.withAlphaComponent(0.2)),
                      Comet(startPoint: CGPoint(x: 0.4 * width, y: 0.6 * height),
                            endPoint: CGPoint(x: 0.3 * width, y: 0.5 * height),
                            lineColor: UIColor.white.withAlphaComponent(0.2))]
        for comet in comets {
            view.layer.addSublayer(comet.drawLine())
            view.layer.addSublayer(comet.animate())
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



