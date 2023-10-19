//
//  UIViewController+Convenience.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 26.05.2022.
//

import AVFoundation
import PKHUD
import SafariServices
import UIKit

extension UIViewController {

    func topViewController() -> UIViewController {
        if let controller = (self as? UINavigationController)?.visibleViewController {
            return controller.topViewController()
        } else if let controller = (self as? UITabBarController)?.selectedViewController {
            return controller.topViewController()
        } else if let controller = presentedViewController {
            return controller.topViewController()
        }
        return self
    }

    func showHUD() {
        HUD.show(.progress)
    }

    func hideHUD() {
        HUD.hide()
    }

    func openLinkURL(_ link: URL?) {
        guard let url = link else {
            return
        }
        let viewController = SFSafariViewController(url: url)
        present(viewController, animated: true)
    }

    func applyTransparentAppearance(color: UIColor = .appClear) {
        let appearance = UINavigationBarAppearance(transparent: true, color: color)
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    func setDismissLeftBarButtonItem(title: String = ^String.ButtonTitles.closeButtonTitle, target: Any = self, selector: Selector = #selector(dismissHandler)) {
        let leftBarButton = UIButton(type: .system)
        leftBarButton.setTitle(title, for: .normal)
        leftBarButton.titleLabel?.font = .regular(17)
        leftBarButton.tintColor = .appOrange
        leftBarButton.addTarget(target, action: selector, for: .touchDown)

        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButton)
        navigationItem.leftBarButtonItem = leftBarButtonItem
    }

    @objc private func dismissHandler() {
        dismiss(animated: true)
    }

    class func ensureCameraPermission(_ completion: @escaping (Bool) -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        guard status == .notDetermined else {
            completion(status == .authorized)
            return
        }
        AVCaptureDevice.requestAccess(for: .video) { authorized in
            DispatchQueue.main.async {
                completion(authorized)
            }
        }
    }

    func showResultViewController(_ model: ScanModel) {
        if model.type == .pdf {
            let documentViewController = DocumentScanResultViewController(document: model)
            presentFullScreenController(controller: documentViewController)
        } else if model.type == .product {
            let resultController = ProductResultCardViewController()
            resultController.toolbarPresenter = ScanResultToolbarPresenter(model: model, controller: resultController)
            let presenter = ProductResultPresenter(
                controller: resultController,
                dataOrigin: .byBarcode(barcode: model.data)
            )
            presenter.codeInfoCardPresenter = CodeInfoCardPresenter(model: model, controller: resultController, cardInfo: .barcodeInfo)
            presenter.foodInfoPresenters = [
                CommonFoodInfoCardPresenter(controller: resultController),
                NutrientsFoodInfoCardPresenter(controller: resultController),
                MicronutrientsFoodInfoCardPresenter(controller: resultController)
            ]
            resultController.presenter = presenter
            presentFullScreenController(controller: resultController)
        } else {
            let controller = ScanResultCardViewController()
            controller.toolbarPresenter = ScanResultToolbarPresenter(model: model, controller: controller)

            let cardInfo: CardInfo = model.type == .qr ? .qrInfo : .barcodeInfo
            let codeInfoPresenter = CodeInfoCardPresenter(model: model, controller: controller, cardInfo: cardInfo)
            var presenters: [AbstractCardPresenter] = [codeInfoPresenter]
            if cardInfo == .barcodeInfo {
                let barcodeSearchPresenter = BarcodeSearchCardPresenter(barcode: model.data, controller: controller)
                presenters.append(barcodeSearchPresenter)
            }

            controller.staticPresenters = presenters
            presentFullScreenController(controller: controller)
        }
    }

    func presentFullScreenController(controller: UIViewController) {
        let navigationVC = AppNavigationController(rootViewController: controller)
        navigationVC.modalPresentationStyle = .fullScreen
        present(navigationVC, animated: true)
    }

}
