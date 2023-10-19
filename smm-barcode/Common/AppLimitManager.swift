//
//  AppLimitManager.swift
//  smm-barcode
//
//  Created by Daniil on 08.03.2023.
//

import Foundation

enum AppLimitsManagerKey: String {
    case barcode
    case product
    case document

    var limit: Int {
        switch self {
        case .barcode:
            return 3
        case .product:
            return 3
        case .document:
            return 3
        }
    }
}

class AppLimitsManager: PreferenceManager<AppLimitsManagerKey> {

    static let shared = AppLimitsManager()

    var barcodeLimit: Int {
        return AppLimitsManagerKey.barcode.limit
    }

    var productLimit: Int {
        return AppLimitsManagerKey.product.limit
    }

    var documentLimit: Int {
        return AppLimitsManagerKey.document.limit
    }

    var barcodeScans: Int {
        get {
            return integer(for: .barcode)
        } set {
            setInteger(min(max(0, newValue), barcodeLimit), for: .barcode)
        }
    }

    var productScans: Int {
        get {
            return integer(for: .product)
        } set {
            setInteger(min(max(0, newValue), productLimit), for: .product)
        }
    }

    var documentScans: Int {
        get {
            return integer(for: .document)
        } set {
            setInteger(min(max(0, newValue), documentLimit), for: .document)
        }
    }

}
