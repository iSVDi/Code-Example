//
//  ScanResultToolbarPresenter.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 03.04.2023.
//

import Foundation
import Toast_Swift
import UIKit

class ScanResultToolbarPresenter {

    private var model: ScanModel!
    private weak var controller: UIViewController?

    init(model: ScanModel, controller: UIViewController) {
        self.model = model
        self.controller = controller
    }

    func buildToolbarView() -> UIToolbar {
        let toolbar = UIToolbar(frame: .init(origin: .zero, size: CGSize(width: Constants.screenWidth, height: 44)))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let toolbarCopyBtn = UIBarButtonItem(image: .commonCopy)
        let toolbarRemoveBtn = UIBarButtonItem(image: .commonRemove, tint: .appSystemRed)
        let toolbarShareBtn = UIBarButtonItem(image: .commonShare)
        toolbar.setItems([toolbarRemoveBtn, spacer, toolbarCopyBtn, spacer, toolbarShareBtn], animated: true)

        if #available(iOS 14.0, *) {
            let menuItems = [
                UIAction(title: ^String.ScanResult.shareAsText, image: AppImage.commonDocImage.uiImageWith(tint: .appOrange), handler: { [weak self] _ in self?.shareAsText() }),
                UIAction(title: ^String.ScanResult.shareAsImage, image: AppImage.photo.uiImageWith(tint: .appOrange), handler: { [weak self] _ in self?.shareAsImage() })
            ]
            toolbarShareBtn.menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
        } else {
            // Fallback on earlier versions
            toolbarShareBtn.addTarget(self, action: #selector(showSheetAlert))
        }

        toolbarCopyBtn.addTarget(self, action: #selector(toolBarCopyHandler))
        toolbarRemoveBtn.addTarget(self, action: #selector(toolBarRemoveHandler))
        return toolbar
    }

    // MARK: - Handlers

    @objc private func showSheetAlert() {
        let barcodeScannerAction = UIAlertAction(title: ^String.ScanResult.shareAsText, style: .default) { [weak self] _ in
            self?.shareAsText()
        }
        let productScannerAction = UIAlertAction(title: ^String.ScanResult.shareAsImage, style: .default) { [weak self] _ in
            self?.shareAsImage()
        }
        let cancelAction = UIAlertAction.cancelAction
        let alertActions: [UIAlertAction] = [barcodeScannerAction, productScannerAction, cancelAction]
        controller?.showSheetAlertController(actions: alertActions)
    }

    @objc func toolBarCopyHandler() {
        UIPasteboard.general.string = model.data
        let message = String.ScanResult.clipboardTitle.format(^String.ScanResult.code)
        controller?.view.makeToast(message)
    }

    @objc func toolBarRemoveHandler() {
        controller?.showDeleteConfirmationAlert { confirmed in
            guard confirmed else {
                return
            }
            ScannedItemsManager.shared.removeItem(self.model) { [weak self] error in
                guard error != nil else {
                    self?.controller?.dismiss(animated: true)
                    return
                }
                self?.controller?.view.makeToast(error?.localizedDescription)
            }
        }
    }

    func shareAsImage() {
        guard let image = UIImage.barcode(data: model.data, type: model.dataFormat, size: .init(width: 1_000, height: 1_000)) else {
            return
        }
        showActivityIndicator(activityItems: [image])
    }

    func shareAsText() {
        showActivityIndicator(activityItems: [model.data])
    }

    // MARK: - Helpers

    private func showActivityIndicator(activityItems: [Any]) {
        let viewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        controller?.present(viewController, animated: true)
    }

}
