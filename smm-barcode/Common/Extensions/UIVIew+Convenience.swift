//
//  UIVIew+Convenience.swift
//  smm-barcode
//
//  Created by Daniil on 14.03.2023.
//

import TinyConstraints

extension UIView {

    func wrap(horizontalInsets: CGFloat = 16, verticalInsets: CGFloat = 11) -> UIView {
        let wrapView = UIView()
        wrapView.addSubview(self)
        edgesToSuperview(insets: .horizontal(horizontalInsets) + .vertical(verticalInsets))
        return wrapView
    }
}
