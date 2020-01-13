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
            return UserDefaults.standard.object(forKey: key) as? ValueType ?? defaultValue
        }
        set {
            defaults.set(newValue, forKey: key)
        }
    }
    
    public init(key: String, defaultValue: ValueType, defaults: UserDefaults = UserDefaults.standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.defaults = defaults
    }
    
}
