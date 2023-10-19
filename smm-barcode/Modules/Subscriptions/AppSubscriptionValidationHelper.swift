//
//  AppSubscriptionValidationHelper.swift
//  smm-nft-creator
//
//  Created by Timur Pervov on 06.04.2022.
//

import SwiftyStoreKit

enum AppSubscriptionKeys: String {
    case subscriptionReshedule
    case subscriptionProductId
    case subscriptionTransactionId
    case subscriptionExpiryDate
    case subscriptionActive
    case subscriptionLastUpdate
}

enum AppSubscriptionValidationError: String, LocalizedError {
    case unknown
    case noActiveSubscription

    var localizedDescription: String {
        switch self {
        case .unknown:
            return ^String.Subscriptions.unknownErrorTitle
        case .noActiveSubscription:
            return ^String.Subscriptions.subscriptionRestoreNoActiveSubMessage
        }
    }

}

class AppSubscriptionValidationHelper: PreferenceManager<AppSubscriptionKeys> {

    private let defaultResheduleInterval: TimeInterval = 300
    private var isFirstTime = true

    var updateHandler: ((Bool) -> Void)?
    var activeSubscriptionType: AppSubscriptionType? {
        return AppSubscriptionType(rawValue: string(for: .subscriptionProductId))
    }

    private let identifiers = AppSubscriptionType.allCases.map { $0.rawValue }
    private(set) var hasActiveSubscription = false {
        didSet {
            setBool(hasActiveSubscription, for: .subscriptionActive)
            guard oldValue != hasActiveSubscription else {
                return
            }
            updateHandler?(hasActiveSubscription)
        }
    }

    override init() {
        super.init()
        hasActiveSubscription = bool(for: .subscriptionActive)
        checkStatusLocally()
    }

    func verifyReceiptWithServer(completion: @escaping (Error?) -> Void) {
        guard let receipt = getReceipt() else {
            completion(AppSubscriptionValidationError.noActiveSubscription)
            return
        }
        AppSubscriptionsRequest.verifyReceipt(receipt) { [weak self] result in
            switch result {
            case let .success(responseData):
                guard let str = String(data: responseData, encoding: .utf8), !str.starts(with: "fail") else {
                    completion(AppSubscriptionValidationError.unknown)
                    return
                }
                let subscriptions = (try? JSONDecoder().decode([AppSubscriptionModel].self, from: responseData)) ?? []
                self?.savePurchaseInfo(subscriptions: subscriptions)
                self?.checkStatusLocally()
                completion(nil)
            case let .failure(error):
                print(error.localizedDescription)
                completion(error)
            }
        }
    }

    // MARK: - Helpers

    private func getReceipt() -> String? {
        guard let receiptData = SwiftyStoreKit.localReceiptData else {
            return nil
        }
        return receiptData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
    }

    private func savePurchaseInfo(subscriptions: [AppSubscriptionModel]) {
        subscriptions.forEach { info in
            if let id = info.productId, identifiers.contains(id) {
                setString(info.productId ?? "", for: .subscriptionProductId)
                setString(info.originalTransactionId ?? "", for: .subscriptionTransactionId)
                setDouble(defaultResheduleInterval, for: .subscriptionReshedule)

                let now = Date()
                setDouble(now.timeIntervalSince1970, for: .subscriptionLastUpdate)

                if let expiryDate = info.expiryMs {
                    setObject(expiryDate, for: .subscriptionExpiryDate)
                }
            }
        }
    }

    private func handleSubscriptionStatusResponseData(_ data: Data) {
        guard let str = String(data: data, encoding: .utf8) else {
            return
        }
        if str == "inActive" {
            setDouble(Date().timeIntervalSince1970, for: .subscriptionLastUpdate)
        } else {
            let subscriptions = (try? JSONDecoder().decode([AppSubscriptionModel].self, from: data))
            if let subscription = subscriptions?.first, let expiryDate = subscription.expiryMs {
                setObject(expiryDate, for: .subscriptionExpiryDate)
                let resheduleValue = Double(subscription.recheckSchedule ?? "\(defaultResheduleInterval)") ?? defaultResheduleInterval
                let reshedule = max(defaultResheduleInterval, resheduleValue)
                setDouble(reshedule, for: .subscriptionReshedule)
                setString(subscription.productId ?? "", for: .subscriptionProductId)
                setString(subscription.originalTransactionId ?? "", for: .subscriptionTransactionId)
                setDouble(Date().timeIntervalSince1970, for: .subscriptionLastUpdate)
                checkStatusLocally()
            }
        }
    }

    private func checkStatusLocally() {
        let transactionId = string(for: .subscriptionTransactionId)
        guard !transactionId.isEmpty else {
            hasActiveSubscription = false
            print("No purchase found")
            return
        }

        let now = Date()
        let nowSec = now.timeIntervalSince1970
        let nowMs = nowSec * 1_000
        let expiryDateMs = object(for: .subscriptionExpiryDate) as? TimeInterval ?? nowMs

        if expiryDateMs > nowMs {
            print("active sub found using expiry date")
            hasActiveSubscription = true
        } else {
            print("sub expired")
            hasActiveSubscription = false
            if isFirstTime {
                checkSubscriptionStatusOnline()
                return
            }
        }

        let resheduleSec = double(for: .subscriptionReshedule)
        let lastUpdateSec = double(for: .subscriptionLastUpdate)
        let sum = resheduleSec + lastUpdateSec
        if nowSec > sum {
            checkSubscriptionStatusOnline()
        }
    }

    private func checkSubscriptionStatusOnline() {
        let transactionId = string(for: .subscriptionTransactionId)
        guard !transactionId.isEmpty else {
            print("no purchase yet")
            return
        }
        isFirstTime = false
        AppSubscriptionsRequest.checkSubscriptionStatus(transactionId: transactionId) { [weak self] result in
            switch result {
            case let .success(responseData):
                self?.handleSubscriptionStatusResponseData(responseData)
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }

}
