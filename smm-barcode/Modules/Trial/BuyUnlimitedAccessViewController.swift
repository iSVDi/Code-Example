//
//  BuyUnlimitedAccessViewController.swift
//  smm-nft-creator
//
//  Created by Timur Pervov on 06.04.2022.
//

import UIKit

class BuyUnlimitedAccessViewController: UIViewController {

    class func presentFrom(_ from: UIViewController, animated: Bool = true) {
        let viewController = BuyUnlimitedAccessViewController()
        let navigationViewController = AppNavigationController(rootViewController: viewController)
        navigationViewController.modalPresentationStyle = .fullScreen
        from.present(navigationViewController, animated: animated)
    }

    private var presenter: BuyUnlimitedAccessPresenter!

    required init() {
        super.init(nibName: nil, bundle: nil)
        presenter = BuyUnlimitedAccessPresenter(controller: self) { [weak self] in
            self?.dismiss(animated: true)
        }
    }

    @available(*, unavailable) required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appWhite
        presenter.viewHelper.defaultLayoutInView(view)
        presenter.handleViewDidLoad()
    }

}
