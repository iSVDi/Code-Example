//
//  AppSubscriptionModel.swift
//  smm-nft-creator
//
//  Created by Timur Pervov on 06.04.2022.
//

import Foundation

struct AppSubscriptionModel: Codable {

    let id: String?
    let originalTransactionId: String?
    let productId: String?
    let purchaseDate: String?
    let expirationDateMs: String?
    let webOrderLineItemId: String?
    let recheckSchedule: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case originalTransactionId = "original_transaction_id"
        case productId = "product_id"
        case purchaseDate = "purchase_date"
        case expirationDateMs = "expires_date_ms"
        case webOrderLineItemId = "web_order_line_item_id"
        case recheckSchedule
    }

}

extension AppSubscriptionModel {

    var expiryMs: TimeInterval? {
        guard let expiryString = expirationDateMs else {
            return nil
        }
        return TimeInterval(expiryString)
    }

}
