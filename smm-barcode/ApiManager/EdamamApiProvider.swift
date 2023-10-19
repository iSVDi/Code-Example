//
//  EdamamApiProvider.swift
//  smm-barcode
//
//  Created by Ilya Rusalovskiy on 10.04.2023.
//

import Moya

class EdamamApiProvider {

    private let provider = MoyaProvider<EdamamApi>()

    func getAutocomplete(for query: String, completion: @escaping (Result<[String], Error>) -> Void) {
        request(target: .autocomplete(query: query), completion: completion)
    }

    func loadFoodInfo(barcode: String, completion: @escaping (Result<EdamamFoodSearch?, Error>) -> Void) {
        request(target: .loadFoodInfoBarcode(barcode: barcode), completion: completion)
    }

    func loadFoodInfo(name: String, completion: @escaping (Result<EdamamFoodSearch?, Error>) -> Void) {
        request(target: .loadFoodInfoName(name: name), completion: completion)
    }

    func loadNutrients(foodId: String, measureURI: String, completion: @escaping (Result<EdamamNutrients?, Error>) -> Void) {
        request(target: .loadNutrientsInfo(foodId: foodId, measureURI: measureURI), completion: completion)
    }

}

extension EdamamApiProvider {

    private func request<T: Decodable>(target: EdamamApi, completion: @escaping (Result<T, Error>) -> Void) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(T.self, from: response.data)
                    completion(.success(results))
                } catch {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

}
