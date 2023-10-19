//
//  UIViewController+Alerts.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 26.05.2022.
//

import TinyConstraints

extension UIViewController {

    private func showAlertController(title: String?, message: String?, actions: [UIAlertAction], style: UIAlertController.Style = .alert) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        actions.forEach { alertController.addAction($0) }
        present(alertController, animated: true)
    }

    // MARK: - Alerts

    func showErrorAlert(_ error: String?, completion: (() -> Void)? = nil) {
        let okAction = UIAlertAction(title: ^String.ButtonTitles.okButtonTitle, style: .cancel) { _ in completion?() }
        showAlertController(title: ^String.Alerts.errorAlertTitle, message: error, actions: [okAction])
    }

    func showInfoAlert(title: String? = ^String.Alerts.infoAlertTitle, message: String?, completion: (() -> Void)? = nil) {
        let okAction = UIAlertAction(title: ^String.ButtonTitles.okButtonTitle, style: .cancel) { _ in completion?() }
        showAlertController(title: title, message: message, actions: [okAction])
    }

    func showConfirmationAlert(title: String? = ^String.Alerts.areYouSure, message: String? = nil, completion: @escaping ((Bool) -> Void)) {
        let yesAction = UIAlertAction(title: ^String.Alerts.yesTitle, style: .default) { _ in completion(true) }
        let noAction = UIAlertAction(title: ^String.Alerts.noTitle, style: .cancel) { _ in completion(false) }
        showAlertController(title: title, message: message, actions: [yesAction, noAction])
    }

    func showDeleteConfirmationAlert(title: String? = ^String.Alerts.deleteConfirmationTitle, message: String? = nil, completion: @escaping ((Bool) -> Void)) {
        let deleteAction = UIAlertAction(title: ^String.Alerts.deleteTitle, style: .destructive) { _ in completion(true) }
        let cancelAction = UIAlertAction(title: ^String.Common.cancelTitle, style: .cancel) { _ in completion(false) }
        showAlertController(title: title, message: message, actions: [deleteAction, cancelAction])
    }

    func showGoToAppSettingsAlert(message: String) {
        let goAction = UIAlertAction(title: ^String.Alerts.goToSettingsTitle, style: .default) { _ in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            UIApplication.shared.open(url)
        }
        showAlertController(title: ^String.Alerts.askOpenSettingsTitle, message: message, actions: [.cancelAction, goAction])
    }

    func showSheetAlertController(title: String? = nil, message: String? = nil, actions: [UIAlertAction]) {
        showAlertController(title: title, message: message, actions: actions, style: .actionSheet)
    }

}
