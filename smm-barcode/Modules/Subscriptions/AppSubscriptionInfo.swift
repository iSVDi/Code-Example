//
//  AppSubscriptionInfo.swift
//  smm-nft-creator
//
//  Created by Timur Pervov on 06.04.2022.
//

import StoreKit

struct AppSubscriptionInfo {

    let identifier: String
    let type: AppSubscriptionType
    let title = ^String.Subscriptions.threeDaysFreeCellTitle
    var alternativeTitle: String {
        switch type {
        case .monthly:
            return ^String.Subscriptions.monthSubCellTitle
        case .yearly:
            return ^String.Subscriptions.yearSubCellTitle
        }
    }

    private(set) var priceString: String?
    private(set) var alternativePriceString: String?
    private(set) var descriptionString: String?

    mutating func updateInfoWithProduct(_ product: SKProduct) {
        let localizedPriceString = product.localizedPrice ?? "-"
        switch type {
        case .monthly:
            priceString = String.Subscriptions.monthlyCalculatedPrice.format(localizedPriceString)
            alternativePriceString = priceString
            descriptionString = String.Subscriptions.monthSubCellSubtitle.format(localizedPriceString)
        case .yearly:
            let formatter = NumberFormatter()
            formatter.locale = product.priceLocale
            formatter.numberStyle = .currency
            let monthPrice = formatter.string(from: NSNumber(value: Double(truncating: product.price) / 12))
            priceString = String.Subscriptions.monthlyCalculatedPrice.format(monthPrice ?? localizedPriceString)
            alternativePriceString = String.Subscriptions.yearlyCalculatedPrice.format(localizedPriceString)
            descriptionString = String.Subscriptions.yearSubCellSubtitle.format(localizedPriceString)
        }
    }

    init(identifier: String, type: AppSubscriptionType) {
        self.identifier = identifier
        self.type = type
    }

    static func build() -> [AppSubscriptionInfo] {
        return AppSubscriptionType.allCases.map {
            switch $0 {
            case .yearly:
                return AppSubscriptionInfo(identifier: $0.rawValue, type: .yearly)
            case .monthly:
                return AppSubscriptionInfo(identifier: $0.rawValue, type: .monthly)
            }
        }
    }

}
