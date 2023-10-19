//
//  AppDelegate.swift
//  smm-barcode
//
//  Created by Daniil on 06.03.2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppSetupManager.setup()
        window = UIWindow(frame: UIScreen.main.bounds)
        AppNavigator.shared.setupRootNavigationInWindow(window)
        window?.makeKeyAndVisible()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppSetupManager.startAppsFlyer()
    }

}
