//
//  Error+Convenience.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 13.05.2022.
//

import Foundation

extension NSError {

    static func getErrorWithDescription(_ description: String, code: Int = -1, domain: AnyClass? = nil) -> NSError {
        let domain = String(describing: domain ?? self)
        return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: description])
    }

}
