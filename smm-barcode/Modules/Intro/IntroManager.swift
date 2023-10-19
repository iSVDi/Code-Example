//
//  IntroManager.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 13.05.2022.
//

import Foundation

enum IntroManagerKeys: String {
    case introAlreadyShowed
}

class IntroManager: PreferenceManager<IntroManagerKeys> {

    var introAlreadyShowed: Bool {
        get {
            bool(for: .introAlreadyShowed)
        } set {
            setBool(newValue, for: .introAlreadyShowed)
        }
    }

}
