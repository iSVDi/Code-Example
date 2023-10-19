//
//  AppTrackingPermission.swift
//  smm-authenticator
//
//  Created by Timur Pervov on 11.01.2022.
//

import AppTrackingTransparency

class AppTrackingPermission {

    class func requestIDFA(completion: @escaping () -> Void) {
        if #available(iOS 14, *), ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            completion()
        }
    }

}
