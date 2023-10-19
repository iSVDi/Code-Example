//
//  EdamamNutrients.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 10.04.2023.
//

import Foundation

struct EdamamNutrient: Encodable, Decodable {
    let label: String
    let quantity: Double
    let unit: String
}

struct EdamamNutrients: Encodable, Decodable {
    let calories: Int?
    let totalWeight: Int?
    let dietLabels: [String]
    let healthLabels: [String]
    let totalNutrients: [String: EdamamNutrient]
    let totalDaily: [String: EdamamNutrient]

    static let baseNutrientKeys = [
        "ENERC_KCAL",
        "PROCNT",
        "FAT",
        "CHOCDF",
        "FIBTG"
    ]

}
