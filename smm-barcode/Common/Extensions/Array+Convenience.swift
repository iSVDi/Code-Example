//
//  Array+Convenience.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 26.05.2022.
//

import Foundation

extension Array {

    subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        return self[index]
    }

}
