//
//  AbstractCardPresenter.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 02.04.2023.
//

import Foundation
import UIKit

class AbstractCardPresenter {

    weak var controller: UIViewController?

    init(controller: UIViewController) {
        self.controller = controller
    }

    // MARK: - Base

    func cardView() -> UIView {
        return UIView()
    }

    final func getSeparatorView(axis: NSLayoutConstraint.Axis = .horizontal) -> UIView {
        let separator = ViewsFactory.separatorLine(axis: axis)
        if axis == .horizontal {
            let separatorView = UIView()
            separatorView.addSubview(separator)
            separator.horizontalToSuperview(insets: .left(16))
            return separatorView
        }
        return separator
    }

}
