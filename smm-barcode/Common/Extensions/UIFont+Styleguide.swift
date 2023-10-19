//
//  UIFont+Styleguide.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 26.05.2022.
//

import UIKit

extension UIFont {

    static func regular(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }

    static func medium(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .medium)
    }

    static func semibold(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .semibold)
    }

    static func bold(_ size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }

}
