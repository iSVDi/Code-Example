//
//  UIAlertAction+Convenience.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 30.05.2022.
//

import UIKit

extension UIAlertAction {

    static var cancelAction: UIAlertAction {
        return UIAlertAction(title: ^String.Common.cancelTitle, style: .cancel)
    }

}
