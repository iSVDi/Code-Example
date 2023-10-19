//
//  Constants.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 13.05.2022.
//

import UIKit

class Constants {

    static let isIpad = UIDevice.current.userInterfaceIdiom == .pad
    static let screenWidth = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
    static let screenHeight = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width)
    static let isSmallScreen = screenWidth == 320 // 5s, se
    static let scale = UIScreen.main.scale

    static let bottomSafeArea = AppNavigator.shared.window?.safeAreaInsets.bottom ?? 0
    static let hasNotch = bottomSafeArea > 0
    static let statusBarHeight: CGFloat = hasNotch ? 44 : 20

    static let privacyURL = URL(string: "https://www.9apps.cz/privacy-vault/")
    static let tosURL = URL(string: "https://www.9apps.cz/terms-vault/")
    static let supportURL = URL(string: "https://www.9apps.cz/")
    static let appStorePath = "https://apps.apple.com/app/id1622151473/"
    static let dateFormat = "yyyy-MM-dd hh:mm:ss"
    static let noTimeDateFormat = "yyyy-MM-dd"
    static let fileNameSeparator = ","

}
