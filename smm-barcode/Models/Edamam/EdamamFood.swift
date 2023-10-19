//
//  EdamamFood.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 10.04.2023.
//

import Foundation

struct EdamamMeasure: Encodable, Decodable {
    let label: String
    let uri: String
}

struct EdamamFood: Encodable, Decodable {
    let foodId: String
    let label: String
    let nutrients: [String: Double]?
    let category: String
    let categoryLabel: String
}

struct EdamamParsedFood: Encodable, Decodable {
    let food: EdamamFood
    let measure: EdamamMeasure?
}

struct EdamamHintFood: Encodable, Decodable {
    let food: EdamamFood
    let measures: [EdamamMeasure]
}

struct EdamamFoodSearch: Encodable, Decodable {
    let parsed: [EdamamParsedFood]
    let hints: [EdamamHintFood]
}
