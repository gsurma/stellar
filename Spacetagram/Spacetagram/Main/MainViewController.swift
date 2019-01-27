//
//  MainViewController.swift
//  Spacetagram
//
//  Created by Greg on 1/26/19.
//  Copyright © 2019 GS. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setMotionEffects()
        loadPictureOfTheDay()
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



