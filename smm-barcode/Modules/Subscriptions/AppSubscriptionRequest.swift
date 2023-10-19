//
//  AppSubscriptionRequest.swift
//  smm-nft-creator
//
//  Created by Timur Pervov on 06.04.2022.
//

import Foundation

class AppSubscriptionsRequest {

    typealias SubscriptionRequestHandler = (Result<Data, Error>) -> Void

    class func verifyReceipt(_ receipt: String, completion: @escaping SubscriptionRequestHandler) {
        guard let url = URL(string: "https://nineappsvalidation.com/photoVault/apis/verifyReceipt.php") else {
            return
        }
        makePOSTRequestToURL(url, params: ["receipt": receipt], completion: completion)
    }

    class func checkSubscriptionStatus(transactionId: String, completion: @escaping SubscriptionRequestHandler) {
        guard let url = URL(string: "https://nineappsvalidation.com/photoVault/apis/checkSubStatus.php") else {
            return
        }
        makePOSTRequestToURL(url, params: ["original_transaction_id": transactionId], completion: completion)
    }

    // MARK: - Helpers

    private class func makePOSTRequestToURL(_ url: URL, params: [String: String], completion: @escaping SubscriptionRequestHandler) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        var paramsString = ""
        params.forEach { paramsString += "\($0.key)=\($0.value)&" }
        let paramsData = paramsString.data(using: .utf8)

        let completionOnMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = URLSession.shared.uploadTask(with: request, from: paramsData) { data, response, error in
            if let response = response as? HTTPURLResponse {
                guard (200 ... 299).contains(response.statusCode) else {
                    let serverError = NSError.getErrorWithDescription("Server error", code: response.statusCode, domain: AppSubscriptionsRequest.self)
                    completionOnMainThread(.failure(serverError))
                    return
                }
                guard let responseData = data else {
                    let unknownError = NSError.getErrorWithDescription("Unknown error", code: response.statusCode, domain: AppSubscriptionsRequest.self)
                    completionOnMainThread(.failure(unknownError))
                    return
                }
                completionOnMainThread(.success(responseData))
            } else {
                let err = error ?? NSError.getErrorWithDescription("Unknown error", code: 500, domain: AppSubscriptionsRequest.self)
                completionOnMainThread(.failure(err))
            }
        }
        task.resume()
    }

}
