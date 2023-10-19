//
//  AppSubscriptionManager.swift
//  smm-nft-creator
//
//  Created by Timur Pervov on 06.04.2022.
//

import SwiftyStoreKit

enum AppSubscriptionType: String, CaseIterable {
    case yearly = "com.photovault.1year"
    case monthly = "com.photovault.1month"
}

protocol AppSubscriptionManagerDelegate: AnyObject {
    func subscriptionStateUpdated(_ active: Bool)
}

class AppSubscriptionManager: WeakDelegatesNotifier {

    static let shared = AppSubscriptionManager()

    private(set) var subscriptionsInfo = AppSubscriptionInfo.build()

    private let validationHelper = AppSubscriptionValidationHelper()
    var activeSubscriptionType: AppSubscriptionType? {
        return validationHelper.activeSubscriptionType
    }

    var hasSubscription: Bool {
        if AppConfig.isDebug {
            return false
        } else {
            return validationHelper.hasActiveSubscription
        }
    }

    override private init() {
        super.init()
        validationHelper.updateHandler = { [weak self] isActive in
            guard let welf = self else {
                return
            }
            welf.delegates.reap()
            welf.delegates
                .compactMap { $0.value as? AppSubscriptionManagerDelegate }
                .forEach { $0.subscriptionStateUpdated(isActive) }
        }
    }

    func loadSubscriptionPrices(_ completion: @escaping ([AppSubscriptionInfo], Error?) -> Void) {
        let ids = Set(AppSubscriptionType.allCases.map { $0.rawValue })
        SwiftyStoreKit.retrieveProductsInfo(ids) { [weak self] result in
            if let error = result.error {
                completion([], error)
            } else {
                result.retrievedProducts
                    .forEach { product in
                        let index = self?.subscriptionsInfo.firstIndex {
                            $0.type.rawValue == product.productIdentifier
                        }
                        guard let index = index else {
                            return
                        }
                        self?.subscriptionsInfo[index].updateInfoWithProduct(product)
                    }
                completion(self?.subscriptionsInfo ?? [], nil)
            }
        }
    }

    func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                let state = purchase.transaction.transactionState
                switch state {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break // do nothing
                }
            }
        }
    }

    // completion returns true if cancelled
    func buySubscription(_ identifier: String, completion: @escaping (Error?, Bool) -> Void) {
        SwiftyStoreKit.purchaseProduct(identifier) { [weak self] result in
            switch result {
            case .success:
                self?.verifySubscriptions { _, _ in
                    completion(nil, false)
                }
            case let .error(error):
                completion(error, error.code == .paymentCancelled)
            }
        }
    }

    // completion returns true if there is an active subscription
    func restoreSubscription(_ completion: @escaping (Bool, Error?) -> Void) {
        SwiftyStoreKit.restorePurchases { [weak self] results in
            if results.restoredPurchases.isEmpty {
                completion(false, results.restoreFailedPurchases.first?.0)
            } else {
                self?.verifySubscriptions(completion)
            }
        }
    }

    // MARK: - Helpers

    // completion returns true if there is an active subscription
    private func verifySubscriptions(_ completion: @escaping (Bool, Error?) -> Void) {
        validationHelper.verifyReceiptWithServer { [weak self] error in
            guard let welf = self else {
                return
            }
            completion(welf.hasSubscription, error)
        }
    }

}
