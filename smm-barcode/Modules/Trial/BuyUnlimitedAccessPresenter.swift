//
//  BuyUnlimitedAccessPresenter.swift
//  smm-nft-creator
//
//  Created by Timur Pervov on 06.04.2022.
//

import UIKit

class BuyUnlimitedAccessViewHelper {

    let trialSlideView = BuyUnlimitedAccessSlideView()
    let continueButton = ViewsFactory.continueButton()
    let tosButton = ViewsFactory.tosPrivacyButton()
    let privacyButton = ViewsFactory.tosPrivacyButton()

    let closeBarButton = ViewsFactory.defaultBarButton(image: .commonClose, color: .appSystemGray2)
    let restoreBarButton = ViewsFactory.defaultBarButton(font: .semibold(13), color: .appSystemGray2)

    func setTitles() {
        continueButton.setTitle(^String.ButtonTitles.continueButtonTitle, for: .normal)
        tosButton.setTitle(^String.Trial.termsOfUsage, for: .normal)
        privacyButton.setTitle(^String.Trial.privacyPolicy, for: .normal)
        restoreBarButton.title = ^String.ButtonTitles.restoreButtonTitle
    }

    func setupNavigationBarForController(_ controller: UIViewController) {
        controller.navigationItem.setLeftBarButton(closeBarButton, animated: true)
        controller.navigationItem.setRightBarButton(restoreBarButton, animated: true)
        controller.applyTransparentAppearance()
    }

    func createPrivacyAndTosView() -> UIView {
        let separatorLine = ViewsFactory.separatorLine(color: .appSystemGray, thickness: 1.5)
        let stackView = ViewsFactory.defaultStackView(spacing: 10, alignment: .center)
        [tosButton, separatorLine, privacyButton].forEach { stackView.addArrangedSubview($0) }
        separatorLine.height(14)
        return stackView
    }

    func defaultLayoutInView(_ view: UIView, slidesView: UIView? = nil, button: UIView? = nil, privacyView: UIView? = nil) {
        let slidesView = slidesView ?? trialSlideView
        let button = button ?? continueButton
        let privacyView = privacyView ?? createPrivacyAndTosView()

        [slidesView, button, privacyView].forEach { view.addSubview($0) }
        slidesView.edgesToSuperview(excluding: .bottom)
        slidesView.bottomToTop(of: button, offset: -14)

        if Constants.isIpad {
            button.centerXToSuperview()
            button.width(IntroConstants().iPadBottomBlockWidth)
        } else {
            button.horizontalToSuperview(insets: IntroConstants().horizontalInsets)
        }
        button.bottomToSuperview(offset: Constants.hasNotch ? -54 : -36)

        privacyView.centerXToSuperview()
        privacyView.topToBottom(of: button, offset: 5)
    }

}

class BuyUnlimitedAccessPresenter {

    private weak var controller: UIViewController!
    private let closeActionHander: () -> Void

    private let subscriptionsManager = AppSubscriptionManager.shared

    let viewHelper = BuyUnlimitedAccessViewHelper()
    private var subscriptionsView: SubscriptionPlansView {
        return viewHelper.trialSlideView.subscriptionsView
    }

    var showsErrors = true

    required init(controller: UIViewController, closeActionHander: @escaping () -> Void) {
        self.controller = controller
        self.closeActionHander = closeActionHander
    }

    func handleViewDidLoad() {
        viewHelper.setTitles()
        viewHelper.setupNavigationBarForController(controller)
        setupButtonHandlers()

        viewHelper.continueButton.isEnabled = false
        subscriptionsView.showSubscriptionPlans(subscriptionsManager.subscriptionsInfo)
        subscriptionsManager.loadSubscriptionPrices { [weak self] plans, error in
            self?.viewHelper.continueButton.isEnabled = true
            if let error = error?.localizedDescription {
                self?.showErrorIfNeeded(error)
            } else {
                self?.subscriptionsView.showSubscriptionPlans(plans)
            }
        }
    }

    // MARK: - Private Helpers

    private func setupButtonHandlers() {
        viewHelper.tosButton.addTarget(self, action: #selector(tosButtonPressed), for: .touchUpInside)
        viewHelper.privacyButton.addTarget(self, action: #selector(privacyButtonPressed), for: .touchUpInside)
        viewHelper.continueButton.addTarget(self, action: #selector(continueButtonPressed), for: .touchUpInside)
        viewHelper.closeBarButton.addTarget(self, action: #selector(closeBarButtonPressed))
        viewHelper.restoreBarButton.addTarget(self, action: #selector(restoreBarButtonPressed))
    }

    private func showErrorIfNeeded(_ error: String) {
        guard showsErrors else {
            return
        }
        controller.showErrorAlert(error)
    }

    // MARK: - Handlers

    @objc private func restoreBarButtonPressed() {
        controller.showHUD()
        subscriptionsManager.restoreSubscription { [weak self] hasActive, error in
            self?.controller.hideHUD()
            if let error = error?.localizedDescription {
                self?.showErrorIfNeeded(error)
            } else {
                let message: String
                if hasActive {
                    message = ^String.Trial.subscriptionRestoreSuccessMessage
                } else {
                    message = ^String.Subscriptions.subscriptionRestoreNoActiveSubMessage
                }
                self?.controller.showInfoAlert(message: message) { [weak self] in
                    guard hasActive else {
                        return
                    }
                    self?.closeBarButtonPressed()
                }
            }
        }
    }

    @objc private func closeBarButtonPressed() {
        closeActionHander()
    }

    @objc private func tosButtonPressed() {
        controller.openLinkURL(Constants.tosURL)
    }

    @objc private func privacyButtonPressed() {
        controller.openLinkURL(Constants.privacyURL)
    }

    @objc func continueButtonPressed() {
        let index = subscriptionsView.selectedIndex
        guard let type = subscriptionsManager.subscriptionsInfo[safeIndex: index]?.type else {
            return
        }
        controller.showHUD()
        subscriptionsManager.buySubscription(type.rawValue) { [weak self] error, cancelled in
            self?.controller.hideHUD()
            guard !cancelled else {
                return
            }
            if let error = error?.localizedDescription {
                self?.showErrorIfNeeded(error)
            } else {
                AppsFlyerAnalytics.trackPurchase(productId: type.rawValue)
                self?.closeBarButtonPressed()
            }
        }
    }

}
