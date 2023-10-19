//
//  AppNavigator.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 13.05.2022.
//

import UIKit

class AppNavigationController: UINavigationController {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return lightContent ? .lightContent : .darkContent
    }

    var lightContent = false

    required init(rootViewController: UIViewController, lightContent: Bool = false) {
        self.lightContent = lightContent
        super.init(rootViewController: rootViewController)
        navigationBar.configureAppNavigationBar()
    }

    @available(*, unavailable) required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AppNavigator {

    static let shared = AppNavigator()
    private(set) var window: UIWindow?
    private let introManager = IntroManager()

    var topViewController: UIViewController? {
        return window?.rootViewController?.topViewController()
    }

    func setupRootNavigationInWindow(_ window: UIWindow?) {
        self.window = window
        if introManager.introAlreadyShowed {
            showScanner()
        } else {
            showIntroController()
        }
    }

    // MARK: - Helpers

    private func showScanner() {
        let viewController = ScannerViewController()
        window?.rootViewController = AppNavigationController(rootViewController: viewController, lightContent: true)
    }

    private func showIntroController() {
        let viewController = IntroViewController { [weak self] in
            self?.introManager.introAlreadyShowed = true
            self?.showScanner()
        }
        window?.rootViewController = AppNavigationController(rootViewController: viewController)
    }

}
