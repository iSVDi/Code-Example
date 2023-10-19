//
//  QLPreviewController+Convenience.swift
//  smm-barcode
//
//  Created by Daniil on 21.04.2023.
//

import QuickLook
import UIKit

extension QLPreviewController {

    static func getQLPreviewControllerWithDelegateAndDataSourceIn(
        _ delegateAndDataSource: (
            datasource: QLPreviewControllerDataSource,
            delegate: QLPreviewControllerDelegate
        ),
        hideBackButton hide: Bool = true
    ) -> QLPreviewController {
        let vc = QLPreviewController()
        vc.delegate = delegateAndDataSource.delegate
        vc.dataSource = delegateAndDataSource.datasource
        vc.navigationItem.setHidesBackButton(hide, animated: false)
        return vc
    }

}
