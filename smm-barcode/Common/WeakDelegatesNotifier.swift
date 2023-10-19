//
//  WeakDelegatesNotifier.swift
//  smm-secret-vault
//
//  Created by Timur Pervov on 13.05.2022.
//

import Foundation

class Weak<T: AnyObject> {

    weak var value: T?

    init(value: T) {
        self.value = value
    }

}

extension Array where Element: Weak<AnyObject> {

    mutating func reap() {
        self = filter { $0.value != nil }
    }

}

class WeakDelegatesNotifier: NSObject {

    var delegates: [Weak<AnyObject>] = []

    func addDelegate(_ delegate: AnyObject) {
        guard !delegates.contains(where: { $0.value === delegate }) else {
            return
        }
        delegates.append(Weak(value: delegate))
    }

    func removeDelegate(_ delegate: AnyObject) {
        guard let index = delegates.firstIndex(where: { $0.value === delegate }) else {
            return
        }
        delegates.remove(at: index)
    }

}
