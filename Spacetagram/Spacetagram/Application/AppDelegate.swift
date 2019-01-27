//
//  AppDelegate.swift
//  Spacetagram
//
//  Created by Greg on 1/26/19.
//  Copyright © 2019 GS. All rights reserved.
//

import UIKit
import Crashlytics
import Fabric

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        Fabric.with([Crashlytics.self])
        return true
    }
}

