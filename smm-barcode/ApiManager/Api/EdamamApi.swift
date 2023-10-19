//
//  EdamamApi.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 10.04.2023.
//

import Moya

private enum EdamamApiConstants {
    // api params
    static let appId = "30adc3a9"
    static let appKey = "6149a27349006b917b28a183951c533c"
    // baseUrl
    static let baseUrl = "https://api.edamam.com"
    // endpoints
    static let autocomplete = "/auto-complete"
    static let parser = "/api/food-database/v2/parser"
    static let nutrients = "/api/food-database/v2/nutrients"
}

enum EdamamApi {
    case autocomplete(query: String)
    case loadFoodInfoName(name: String)
    case loadFoodInfoBarcode(barcode: String)
    case loadNutrientsInfo(foodId: String, measureURI: String)
}

extension EdamamApi: TargetType {

    var baseURL: URL {
        // swiftlint:disable force_unwrapping
        return URL(string: EdamamApiConstants.baseUrl)!
        // swiftlint:enable force_unwrapping
    }

    var path: String {
        switch self {
        case .autocomplete:
            return EdamamApiConstants.autocomplete
        case .loadFoodInfoName, .loadFoodInfoBarcode:
            return EdamamApiConstants.parser
        case .loadNutrientsInfo:
            return EdamamApiConstants.nutrients
        }
    }

    var method: Moya.Method {
        switch self {
        case .loadNutrientsInfo:
            return .post
        default:
            return .get
        }
    }

    var task: Moya.Task {
        switch self {
        case let .autocomplete(query):
            return .requestParameters(parameters: [
                "app_id": EdamamApiConstants.appId,
                "app_key": EdamamApiConstants.appKey,
                "q": query
            ], encoding: URLEncoding.queryString)
        case let .loadFoodInfoName(name):
            return .requestParameters(parameters: [
                "app_id": EdamamApiConstants.appId,
                "app_key": EdamamApiConstants.appKey,
                "ingr": name
            ], encoding: URLEncoding.queryString)
        case let .loadFoodInfoBarcode(barcode):
            return .requestParameters(parameters: [
                "app_id": EdamamApiConstants.appId,
                "app_key": EdamamApiConstants.appKey,
                "upc": barcode
            ], encoding: URLEncoding.queryString)
        case let .loadNutrientsInfo(foodId, measureURI):
            return .requestCompositeParameters(bodyParameters: [
                "ingredients": [
                    [
                        "quantity": 1,
                        "measureURI": "\(measureURI)",
                        "foodId": "\(foodId)"
                    ] as [String: Any]
                ]
            ], bodyEncoding: JSONEncoding.default, urlParameters: [
                "app_id": EdamamApiConstants.appId,
                "app_key": EdamamApiConstants.appKey
            ])
        }
    }

    var headers: [String: String]? {
        switch self {
        case .loadNutrientsInfo:
            return ["Content-Type": "application/json", "Accept": "application/json"]
        default:
            return ["Accept": "application/json"]
        }
    }

}
