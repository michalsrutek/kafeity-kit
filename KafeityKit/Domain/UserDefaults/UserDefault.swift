//
//  UserDefault.swift
//  KafeityKit
//
//  Created by SKOUMAL Studio on 13/01/2020.
//  Copyright © 2020 SKOUMAL, s.r.o. All rights reserved.
//

import Foundation


@propertyWrapper
public struct UserDefault<ValueType> {
    
    private let key: String
    private let defaultValue: ValueType
    private let defaults: UserDefaults
    
    public var wrappedValue: ValueType {
        get {
            let udValue = defaults.object(forKey: key) as? ValueType
            switch (udValue as Any) {
            case Optional<Any>.some(let value):
                return value as! ValueType
            case Optional<Any>.none:
                return defaultValue
            default:
                return udValue ?? defaultValue
            }
        }
        set {
            switch (newValue as Any) {
            case Optional<Any>.some(let value):
                defaults.set(value, forKey: key)
            case Optional<Any>.none:
                defaults.removeObject(forKey: key)
            default:
                defaults.set(newValue, forKey: key)
            }
        }
    }
    
    public init(key: String, defaultValue: ValueType, defaults: UserDefaults = UserDefaults.standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults
    }
    
}
