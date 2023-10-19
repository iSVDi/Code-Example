//
//  PreferenceManager.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 13.05.2022.
//

import Foundation

class PreferenceManager<Key: RawRepresentable<String>> {

    private let userDefaults = UserDefaults.standard

    func register(_ defaults: [String: Any]) {
        userDefaults.register(defaults: defaults)
    }

    func string(for key: Key) -> String {
        return userDefaults.string(forKey: key.rawValue) ?? ""
    }

    func setString(_ string: String, for key: Key) {
        userDefaults.setValue(string, forKey: key.rawValue)
    }

    func bool(for key: Key) -> Bool {
        return userDefaults.bool(forKey: key.rawValue)
    }

    func setBool(_ bool: Bool, for key: Key) {
        userDefaults.setValue(bool, forKey: key.rawValue)
    }

    func float(for key: Key) -> Float {
        return userDefaults.float(forKey: key.rawValue)
    }

    func setFloat(_ float: Float, for key: Key) {
        userDefaults.setValue(float, forKey: key.rawValue)
    }

    func double(for key: Key) -> Double {
        return userDefaults.double(forKey: key.rawValue)
    }

    func setDouble(_ double: Double, for key: Key) {
        userDefaults.setValue(double, forKey: key.rawValue)
    }

    func integer(for key: Key) -> Int {
        return userDefaults.integer(forKey: key.rawValue)
    }

    func setInteger(_ int: Int, for key: Key) {
        userDefaults.setValue(int, forKey: key.rawValue)
    }

    func object(for key: Key) -> Any? {
        return userDefaults.object(forKey: key.rawValue)
    }

    func setObject(_ object: Any, for key: Key) {
        userDefaults.setValue(object, forKey: key.rawValue)
    }

    func removeObjectForKey(_ key: Key) {
        userDefaults.removeObject(forKey: key.rawValue)
    }

}
