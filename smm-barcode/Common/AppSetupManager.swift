//
//  AppSetupManager.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 27.05.2022.
//

import AppsFlyerLib
import UIKit

class AppSetupManager {

    class func setup() {
        AppSubscriptionManager.shared.completeTransactions()
        setupAppearance()
    }

    class func startAppsFlyer() {
        AppsFlyerLib.shared().start()
    }

    // MARK: - Helpers

    private class func setupAppearance() {
        let color = UIColor.appLightGray
        let navAppearance = UINavigationBarAppearance(transparent: false, color: color)
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance

        let tabAppearance = UITabBarAppearance()
        tabAppearance.backgroundColor = color
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
    }

}
