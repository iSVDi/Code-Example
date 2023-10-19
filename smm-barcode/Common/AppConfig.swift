//
//  AppConfig.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 13.05.2022.
//

import Foundation

class AppConfig {

    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

}
