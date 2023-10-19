//
//  UINavigationBarAppearance+Convenience.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 26.05.2022.
//

import UIKit

extension UINavigationBarAppearance {

    convenience init(transparent: Bool, color: UIColor) {
        self.init()
        if transparent {
            configureWithTransparentBackground()
        }
        backgroundColor = color
        titleTextAttributes = [.font: UIFont.semibold(17)]
        largeTitleTextAttributes = [.font: UIFont.bold(34)]
        let button = UIBarButtonItemAppearance()
        [button.normal, button.highlighted].forEach {
            $0.titleTextAttributes = [.font: UIFont.regular(17)]
        }
        backButtonAppearance = button
    }

}
