//
//  UITextField+Convenience.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 26.05.2022.
//

import UIKit

extension UITextField {

    func setLeftViewPadding() {
        let paddingSize = CGSize(width: 16, height: 0)
        let paddingView = UIView(frame: CGRect(origin: .zero, size: paddingSize))
        leftView = paddingView
        leftViewMode = .always
    }

}
