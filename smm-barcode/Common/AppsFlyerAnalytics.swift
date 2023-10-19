//
//  AppsFlyerAnalytics.swift
//  smm-authenticator
//
//  Created by vitaly@aiweapps.com on 05.12.2022.
//

import AppsFlyerLib
import Foundation

class AppsFlyerAnalytics {

    class func trackPurchase(productId: String, fromTrial: Bool = true) {
        let contentType = fromTrial ? "from_trial_screen" : "from_settings_subscription_screen"
        let values = [
            AFEventParamContentId: productId,
            AFEventParamContentType: contentType
        ]
        AppsFlyerLib.shared().logEvent(name: AFEventPurchase, values: values) { response, error in
            if let response = response {
                print("In app even callback ✅ SUCCESS: \(response)")
            } else if let error = error {
                print("In app even callback ❌ ERROR: \(error.localizedDescription)")
            }
        }
    }

}
