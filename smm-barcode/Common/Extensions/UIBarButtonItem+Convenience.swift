//
//  UIBarButtonItem+Convenience.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 26.05.2022.
//

import UIKit

extension UIBarButtonItem {

    convenience init(image: AppImage? = nil, tint: UIColor = .appOrange) {
        self.init(image: image?.uiImage, style: .plain, target: nil, action: nil)
        tintColor = tint
    }

    func addTarget(_ target: AnyObject?, action: Selector?) {
        self.target = target
        self.action = action
    }

}
