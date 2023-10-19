//
//  SubscriptionsViewController.swift
//  smm-barcode
//
//  Created by Daniil on 09.03.2023.
//

import UIKit

class SubscriptionsViewController: UIViewController {

    // MARK: - Properties

    private let scrollView = ViewsFactory.defaultScrollView()
    private let parentStackView = ViewsFactory.defaultStackView(axis: .vertical, spacing: 20, distribution: .fillProportionally)
    private let featuresView = BuyUnlimitedAccessFeaturesView()
    private let subscriptionsView = SubscriptionPlansView(isAlternative: true)
    private let subscriptionsManager = AppSubscriptionManager.shared

    private let manager = AppSubscriptionManager.shared

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
    }

    // MARK: - Private Methods

    private func commonInit() {
        setupLayout()
        setupViews()
        setupHandlers()
    }

    private func setupViews() {
        title = ^String.Settings.subscriptionsTitle
        view.backgroundColor = .appLightGray3
        subscriptionsView.showSubscriptionPlans(subscriptionsManager.subscriptionsInfo)
        subscriptionsManager.loadSubscriptionPrices { [weak self] plans, error in
            if let error = error?.localizedDescription {
                print(error)
            } else {
                self?.subscriptionsView.showSubscriptionPlans(plans)
            }
        }
    }

    private func setupLayout() {
        let subscriptionsWrapper = UIView()

        subscriptionsWrapper.addSubview(subscriptionsView)
        subscriptionsView.edgesToSuperview()
        let subscriptionDescriptionLabel = ViewsFactory.defaultLabel(font: .regular(11), textColor: .appLightGray4, alignment: .left, lines: 0, adjustFont: true)

        subscriptionDescriptionLabel.text = ^String.Settings.subscriptionsDescriptionTitle

        [featuresView, subscriptionsWrapper, subscriptionDescriptionLabel].forEach {
            parentStackView.addArrangedSubview($0)
        }

        let constants = IntroConstants()
        view.addSubview(parentStackView)
        parentStackView.topToSuperview(offset: 10, usingSafeArea: true)

        parentStackView.horizontalToSuperview(insets: constants.horizontalInsets)
    }

    private func setupHandlers() {
        subscriptionsView.selectedPlanViewAt = { [weak self] index in
            let info = self?.manager.subscriptionsInfo[safeIndex: index]
            guard let identifier = info?.identifier else {
                return
            }
            guard identifier != self?.manager.activeSubscriptionType?.rawValue else {
                return
            }
            self?.buySubscription(identifier)
        }
    }

    private func buySubscription(_ identifier: String) {
        showConfirmationAlert(message: ^String.Settings.changeSubscriptionTitle) { [weak self] confirmed in
            if confirmed {
                self?.showHUD()
                self?.manager.buySubscription(identifier) { [weak self] error, cancelled in
                    self?.hideHUD()
                    self?.showSubscriptions()
                    guard !cancelled else {
                        return
                    }
                    if let err = error {
                        self?.showErrorAlert(err.localizedDescription)
                    } else {
                        AppsFlyerAnalytics.trackPurchase(productId: identifier, fromTrial: false)
                    }
                }
            } else {}
        }
    }

    private func showSubscriptions() {
        subscriptionsView.showSubscriptionPlans(manager.subscriptionsInfo)
    }

}
